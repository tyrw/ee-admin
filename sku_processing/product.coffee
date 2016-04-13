_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'

utils = require '../utils'

fns = {}

fns.updateProductsSpelling = (reference_products) ->
  info = {}
  Promise.reduce reference_products, ((total, product) -> fns.updateProductSpelling(product, info)), 0
  .then () ->
    utils.setStatus 'spelling', 'Updated ' + reference_products.length + ' products'
    info

fns.updateProductSpelling = (reference_product, info) ->
  return if !reference_product or !reference_product.id or !reference_product.title
  q = 'UPDATE "Products" SET title = ?, content = ?, updated_at = ? WHERE id = ?'
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [reference_product.title, reference_product.content, utils.timestamp(), reference_product.id] }

module.exports = fns
