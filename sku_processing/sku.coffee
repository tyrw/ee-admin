_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'

utils = require '../utils'

fns = {}

fns.editableAttrs = ['supply_price', 'supply_shipping_price', 'quantity', 'msrp', 'discontinued']

fns.findAll = () ->
  sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, auto_pricing, discontinued FROM "Skus"', { type: sequelize.QueryTypes.SELECT }

fns.findByIdentifierAndSupplierId = (identifier, supplier_id) ->
  if supplier_id then supplier_id = parseInt(supplier_id)
  sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, auto_pricing, discontinued FROM "Skus" where identifier = ? AND supplier_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [identifier, supplier_id] }

fns.createFrom = (data, info) ->
  data ||= {}
  info ||= {}
  q = 'INSERT INTO "Skus" ("product_id", "identifier", "baseline_price", "shipping_price", "msrp", "selection_text", "quantity", "discontinued", "supplier_id", "supplier_name", "manufacturer_name", "brand_name", "supply_shipping_price", "supply_price", "meta", "other", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *'
  sequelize.query q, { type: sequelize.QueryTypes.INSERT, replacements: [data.product_id, data.identifier, data.baseline_price, data.shipping_price, data.msrp, data.selection_text, data.quantity, data.discontinued, data.supplier_id, data.supplier_name, data.manufacturer_name, data.brand_name, data.supply_shipping_price, data.supply_price, JSON.stringify(data.meta), JSON.stringify(data.other), utils.timestamp(), utils.timestamp()] }
  .then (res) ->
    info.skus?.created++
    info.skus?.created_ids?.push res[0].id
    res[0]

  # if data.additional_images?.length > 0
  #   additional_images = 'ARRAY[\'' + data.additional_images.join("\',\'") + '\']::VARCHAR(255)[]'
  #   q = q.replace('ARRAY[]::VARCHAR(255)[]', additional_images)
  # sequelize.query q, { type: sequelize.QueryTypes.INSERT, replacements: [data.title, data.content, data.external_identity, data.image, data.category_id, utils.timestamp(), utils.timestamp()] }
  # .then (res) -> res[0]

# fns.findByIdentifiers = (identifiers) ->
#   sequelize.query 'SELECT id, identifier, supplier_id, supply_price, supply_shipping_price, quantity, msrp, discontinued FROM "Skus" where identifier IN (' + identifiers + ')', { type: sequelize.QueryTypes.SELECT }

fns.updatePricing = (sku) ->
  return unless sku? and sku.id? and sku.baseline_price? and sku.shipping_price?
  q = 'UPDATE "Skus" SET baseline_price = ' + parseInt(sku.baseline_price) +
    ', shipping_price = ' + parseInt(sku.shipping_price) +
    ' WHERE id = ? '
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [sku.id] }

fns.updateAttrs = (obj) ->
  return if !obj or !obj.identifier or Object.keys(obj).length < 2
  q = 'UPDATE "Skus" SET '
  for attr, i in fns.editableAttrs
    unless _.isUndefined obj[attr]
      q += '"' + attr + '" = ' + obj[attr] + ", "
  q += ' "updated_at" = ' + "'" + utils.timestamp() + "' "
  q += ' WHERE "identifier" = ? '
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [obj.identifier] }

fns.updateSkus = (reference_skus) ->
  # reference_skus is an array of objects:
  # {
  #   identifier
  #   supplier_id
  #   supply_shipping_price
  #   supply_price
  #   quantity
  #   msrp
  #   discontinued
  # }
  info =
    count:
      total: 0
      updated:
        total: 0
      unchanged: 0
      not_found: 0
      large_price_change: 0
    not_found_identifiers: []
    large_price_change_identifiers: []
  info.count.updated[attr] = 0 for attr in fns.editableAttrs
  Promise.reduce reference_skus, ((total, sku) -> fns.updateSku(sku, info)), 0
  .then () -> info

fns.updateSku = (reference_sku, info) ->
  return if !reference_sku or !reference_sku.identifier
  info ||= {}
  fns.findByIdentifierAndSupplierId reference_sku.identifier, reference_sku.supplier_id
  .then (res) ->
    sku = res[0]
    # Handle not_found
    if !sku or !sku.id
      info.skus?.not_found++
      info.skus?.not_found_ids?.push reference_sku.identifier
      return 'not_found'
    toUpdate = []
    for attr in fns.editableAttrs
      if reference_sku[attr] isnt sku[attr] then toUpdate.push attr
    # Handle unchanged
    if toUpdate.length is 0
      info.skus?.unchanged++
      return 'unchanged'
    # Handle updates
    info.skus?.updated++
    info.skus?.updated_attrs[attr]++ for attr in toUpdate
    if (reference_sku.supply_price > sku.supply_price * 1.2) or (reference_sku.supply_shipping_price > sku.supply_shipping_price * 1.2)
      info.skus?.large_price_change++
      info.skus?.large_price_change_ids?.push reference_sku.id
    fns.updateAttrs reference_sku

fns.updateSkusSpelling = (reference_skus) ->
  info = {}
  Promise.reduce reference_skus, ((total, sku) -> fns.updateSkuSpelling(sku, info)), 0
  .then () ->
    utils.setStatus 'spelling', 'Updated ' + reference_skus.length + ' skus'
    info

fns.updateSkuSpelling = (reference_sku, info) ->
  return if !reference_sku or !reference_sku.id or !reference_sku.selection_text
  q = 'UPDATE "Skus" SET selection_text = ?, updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [reference_sku.selection_text, utils.timestamp(), reference_sku.id] }

module.exports = fns
