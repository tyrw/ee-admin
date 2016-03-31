_       = require 'lodash'
Promise = require 'bluebird'
argv    = require('yargs').argv

dropbox = require './dropbox'
csv     = require './csv'
sku     = require './sku'
utils   = require './utils'

processFile = (path) ->
  dropbox.getFile path
  .then (file) -> csv.parseFile file
  .then (skus) -> sku.updateSkus skus
  .then (count) ->
    console.log count
    count

if argv.update
  ### coffee sku_processing/runner.coffee --update ###
  dropbox.getFolder '/update'
  .then (rows) ->
    files = _.filter rows.entries, { '.tag': 'file' }
    Promise.reduce files, ((total, file) -> processFile file.path_lower), 0
  .catch (err) -> console.log 'err', err
  .finally () -> process.exit()
  # console.log utils.timestamp()
  # process.exit()

else if argv.download
  ### coffee sku_processing/runner.coffee --download ###
  dropbox.getFile '/update/artwork.csv'
  # dropbox.getFolder '/update'
  .then (rows) ->
    console.log rows
    # console.log rows.length
  .catch (err) -> console.log 'err', err
  .finally () ->  process.exit()

else if argv.move
  ### coffee sku_processing/runner.coffee --move ###
  payload = dropbox.setPayload 'move', { file_path: '/update/artwork.csv' }
  request.post payload, (err, res, body) ->
    if !err and res.statusCode is 200
      console.log res
      console.log body
      process.exit()
    else
      console.log 'err', err
      process.exit()

else
  console.log "No scenario was matched"
  console.log 'NODE_ENV', process.env.NODE_ENV
  process.exit()