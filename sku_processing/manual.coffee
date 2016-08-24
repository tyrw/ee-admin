fs        = require 'fs'
_         = require 'lodash'
Promise   = require 'bluebird'
sequelize = require '../config/sequelize/setup'
argv      = require('yargs').argv

sku     = require './sku'
pricing = require './pricing'
es      = require './elasticsearch'

utils   = require '../utils'

setProductTitleAndContent = (product_id, title, content) ->
  q = "UPDATE \"Products\" SET title = ?, content = ? WHERE id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [title, content, product_id] }

setSkuDimensionsForProduct = (product_id, length, width, height) ->
  q = "UPDATE \"Skus\" SET length = ?, width = ?, height = ? WHERE product_id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [length, width, height, product_id] }

setSkuDimensions = (id, length, width, height) ->
  q = "UPDATE \"Skus\" SET length = ?, width = ?, height = ? WHERE id = ?"
  sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [length, width, height, id] }

updateIfDimensioned = (sku) ->
  return unless sku?.meta?.attributes?
  pairs = _.map sku.meta.attributes.split(/\|\|/g)
  attrs = {}
  for pair in pairs
    if pair.split(':=')[0] is 'Product1 D (in)' then sku.length = parseFloat(pair.split(':=')[1]) || null
    if pair.split(':=')[0] is 'Product1 W (in)' then sku.width  = parseFloat(pair.split(':=')[1]) || null
    if pair.split(':=')[0] is 'Product1 H (in)' then sku.height = parseFloat(pair.split(':=')[1]) || null
    if pair.split(':=')[0] is 'Dimensions'
      dimensions = pair.split(':=')[1].replace(/ /g,'').split('x')
      for dim in dimensions
        switch dim.slice(-1)
          when 'L' then sku.length = parseFloat(dim.slice(0,-1))
          when 'W', 'D' then sku.width = parseFloat(dim.slice(0,-1))
          when 'H' then sku.height = parseFloat(dim.slice(0,-1))
  if sku.length? or sku.width? or sku.height?
    setSkuDimensions sku.id, sku.length, sku.width, sku.height
  else
    Promise.resolve true

formTagTree = () ->
  # write tag tree to tree.txt
  tree = {}
  toWrite = ''
  sku.findAll()
  .then (skus) ->
    for sku in skus
      if sku.tags?.length > 0
        for tag, i in sku.tags
          if tag? and tag isnt ''
            switch i
              when 0
                if tree[tag]? then tree[tag].count += 1 else tree[tag] = { count: 1 }
              when 1
                if tree[sku.tags[0]][tag]? then tree[sku.tags[0]][tag].count += 1 else tree[sku.tags[0]][tag] = { count: 1 }
              when 2
                if tree[sku.tags[0]][sku.tags[1]][tag]? then tree[sku.tags[0]][sku.tags[1]][tag].count += 1 else tree[sku.tags[0]][sku.tags[1]][tag] = { count: 1 }
    for key in Object.keys tree
      toWrite += key + ' (' + tree[key].count + ')\n'
      for subkey in Object.keys tree[key]
        if subkey isnt 'count'
          toWrite += '\t- ' + subkey + ' (' + tree[key][subkey].count + ')\n'
          for subsubkey in Object.keys tree[key][subkey]
            if subsubkey isnt 'count'
              toWrite += '\t\t- ' + subsubkey + ' (' + tree[key][subkey][subsubkey].count + ')\n'
    console.log toWrite
    fs.writeFileSync 'tree.txt', toWrite

if argv.bedding_vermicelli
  ### coffee sku_processing/manual.coffee --bedding_vermicelli ###
  product_count = 0
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%quilt%' AND length is null; 93
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%blanket%' AND length is null; 130
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%throw%' AND length is null; 120
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%throw blanket%' AND length is null; 93
  # SELECT count(*) from "Skus" WHERE selection_text ilike '%comforter%' AND length is null; 150
  q = "SELECT id, title, content FROM \"Products\" WHERE title ilike '[%' AND title ilike '%3PC Vermicelli%' AND title ilike '%Queen%'"
  sequelize.query q, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count = products.length
    updateSkus = (product_id) ->
      q = "UPDATE \"Skus\" SET length = 98, width = 90 WHERE product_id = ?"
      sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [product_id] }
    updateProduct = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      prod.title = style + ' Vermicelli Quilt and 2 Shams, Full or Queen Size'
      prod.content = 'Set includes a quilt and two quilted shams. Shell and fill are 100% cotton. For convenience, all bedding components are machine washable on cold in the gentle cycle and can be dried on low heat and will last you years. Intricate vermicelli quilting provides a rich surface texture. This vermicelli-quilted quilt set will refresh your bedroom decor instantly, create a cozy and inviting atmosphere and is sure to transform the look of your bedroom or guest room.\n\nDimensions: Full/Queen quilt: 90 inches x 98 inches\n2 standard shams: 20 inches x 26 inches'
      q = "UPDATE \"Products\" SET title = ?, content = ? WHERE id = ?"
      sequelize.query q, { type: sequelize.QueryTypes.UPDATE, replacements: [prod.title, prod.content, prod.id] }
      .then () -> updateSkus prod.id
    Promise.reduce products, ((total, product) -> updateProduct(product)), 0
  .then (res) ->  console.log 'finished ' + product_count + ' products'
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()

else if argv.onitiva
  ### coffee sku_processing/manual.coffee --onitiva ###
  product_count = 0
  # SELECT count(*) from "Products" WHERE title ilike '%onitiva%' and title ilike '%throw%' AND title ilike '%78.7%';
  # SELECT id, title from "Products" WHERE title ilike '%onitiva%' and title ilike '%floor cushion%' AND title ilike '%19.7%';
  q1 = "SELECT id, title from \"Products\" WHERE title ilike '%onitiva%' AND title ilike '%throw%' AND title ilike '%78.7%'" # 57
  q2 = "SELECT id, title from \"Products\" WHERE title ilike '%onitiva%' AND title ilike '%throw%' AND title ilike '%86.6%'" # 14
  q3 = "SELECT id, title from \"Products\" WHERE title ilike '%onitiva%' AND title ilike '%floor cushion%' AND title ilike '%19.7%'" # 50

  sequelize.query q1, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count += products.length
    updateProduct1 = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      title = style + ' Throw Blanket'
      content = 'This blanket measures 59 by 78.7 inches. Suitable for home or travel. Soft materials and high tenacity; Fine and concentrated stitches; Machine washable and dryable. Exquisitely soft, and effortlessly warm! You have to feel this throw to believe the softness. Front: 100% Coral Fleece, Back: Plush. Fashionable and elegant blanket, perfect for your bedroom.\n\nThis Patchwork Throw Blanket measures 59 by 78.7 inches. Comfort, warmth and stylish designs. Whether you are adding the final touch to your bedroom or rec-room these patterns will add a little whimsy to your decor. This Coral Fleece Patchwork throw blanket will make a fun additional to any room and are beautiful draped over a sofa, chair, bottom of your bed and handy to grab and snuggle up in when there is a chill in the air. They are the perfect gift for any occasion! Keep one in your car for staying warm at outdoor sporting events. Place one on your couch or favorite upholstered chair. Have extras on hand for sleepovers and overnight guests. Machine wash and tumble dry for easy care. Will look and feel as good as new after multiple washings!'
      setProductTitleAndContent prod.id, title, content
      .then () -> setSkuDimensionsForProduct prod.id, 78.7, 59, null
    Promise.reduce products, ((total, product) -> updateProduct1(product)), 0
  .then () ->
    sequelize.query q2, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count += products.length
    updateProduct2 = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      title = style + ' Throw Blanket'
      content = 'This blanket measures 61 by 86.6 inches. Suitable for home or travel. Soft materials and high tenacity; Fine and concentrated stitches; Machine washable and dryable. Exquisitely soft, and effortlessly warm! You have to feel this throw to believe the softness. Front: 100% Coral Fleece, Back: Plush. Fashionable and elegant blanket, perfect for your bedroom.\n\nThis Throw Blanket measures 61 by 86.6 inches. Comfort, warmth and stylish designs. Whether you are adding the final touch to your bedroom or rec-room these patterns will add a little whimsy to your decor. This Coral Fleece Patchwork throw blanket will make a fun additional to any room and are beautiful draped over a sofa, chair, bottom of your bed and handy to grab and snuggle up in when there is a chill in the air. They are the perfect gift for any occasion! Keep one in your car for staying warm at outdoor sporting events. Place one on your couch or favorite upholstered chair. Have extras on hand for sleepovers and overnight guests. Machine wash and tumble dry for easy care. Will look and feel as good as new after multiple washings!'
      setProductTitleAndContent prod.id, title, content
      .then () -> setSkuDimensionsForProduct prod.id, 86.6, 61, null
    Promise.reduce products, ((total, product) -> updateProduct2(product)), 0
  .then () ->
    sequelize.query q3, { type: sequelize.QueryTypes.SELECT }
  .then (products) ->
    product_count += products.length
    updateProduct3 = (prod) ->
      style = prod.title.match(/\[.*\]/g)[0].replace(/[\[\]]/g,'')
      title = style + ' Pillow Cushion'
      content = 'This stylish decorative pillow measures 19.7 by 19.7 inches with creative design pattern.\n\nAesthetics and Functionality Combined. Hug and wrap your arms around this stylish decorative pillow measuring 19.7 by 19.7 inches, offering a sense of warmth and comfort to home and outdoor alike. Find a friend in its team of skilled and creative designers as they seek to use materials only of the highest quality. This art pillow by Onitiva features contemporary design, modern elegance and fine construction. The pillow is made to have invisible zippers and fill-down alternative. The rich look and feel, extraordinary textures and vivid colors of this comfy pillow transforms an ordinary, dull room into an exciting and luxurious place for rest and recreation. Suitable for your living room, bedroom, office and patio. It will surely add a touch of life, variety and magic to any rooms in your home. The pillow has a hidden side zipper to remove the center fill for easy washing of the cover if needed.'
      setProductTitleAndContent prod.id, title, content
      .then () -> setSkuDimensionsForProduct prod.id, 19.7, 19.7, null
    Promise.reduce products, ((total, product) -> updateProduct3(product)), 0
  .then (res) ->  console.log 'finished ' + product_count + ' products'
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()

else if argv.sku_dimensions
  ### coffee sku_processing/manual.coffee --sku_dimensions ###
  q = "SELECT id, meta FROM \"Skus\" WHERE length IS NULL AND width IS NULL AND height IS NULL AND meta IS NOT NULL"
  # q = "SELECT id, meta FROM \"Skus\" WHERE width IS NULL AND meta IS NOT NULL"
  sequelize.query q, { type: sequelize.QueryTypes.SELECT }
  .then (skus) ->
    console.log skus.length
    Promise.reduce skus, ((total, sku) -> updateIfDimensioned(sku)), 0
  .finally () -> process.exit()

else if argv.test_elasticsearch
  # Change es_index first
  ### coffee sku_processing/manual.coffee --test_elasticsearch ###
  es.deleteNestedIndex()
  .then () -> es.createNestedIndex()
  .then () -> es.bulkNestedIndex()
  .then (count) -> console.log 'count', count
  .catch (err) -> console.log 'err', err
  .finally () ->
    console.log 'finished'
    process.exit()

else if argv.form_tag_tree
  ### coffee sku_processing/manual.coffee --form_tag_tree ###
  formTagTree()
  .catch (err) -> console.log 'err', err
  .finally () ->
    console.log 'finished'
    process.exit()
