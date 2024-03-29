switch process.env.NODE_ENV
  when 'production'
    require 'newrelic'
  when 'test'
    process.env.PORT = 9999
  else
    process.env.NODE_ENV = 'development'
    process.env.PORT = 9000

express     = require 'express'
# vhost       = require 'vhost'
morgan      = require 'morgan'
path        = require 'path'
serveStatic = require 'serve-static'
bodyParser  = require 'body-parser'
compression = require 'compression'

utils       = require './utils'
skuRunner   = require './sku_processing/runner'

# Parent app
app = express()
app.use compression()

forceSsl = (req, res, next) ->
  if req.headers['x-forwarded-proto'] isnt 'https'
    res.redirect [
      'https://'
      req.get('Host')
      req.url
    ].join('')
  else
    next()
  return

if process.env.NODE_ENV is 'production'
  app.use forceSsl
  app.use morgan 'common'
else
  app.use morgan 'dev'

app.all '/favicon.ico', (req, res, next) ->
  res.redirect 'https://res.cloudinary.com/eeosk/image/upload/v1458866623/favicon_lock_2.ico'
  return

# app.post '/v0/processing/create', (req, res, next) ->
#   utils.setStatus 'create', { running: true }
#   res.json global.ee_status
#   return

app.post '/v0/processing/dropbox', (req, res, next) ->
  skuRunner.processDropbox()
  res.json global.ee_status
  return

app.post '/v0/processing/elasticsearch', (req, res, next) ->
  skuRunner.indexElasticsearch()
  res.json global.ee_status
  return

app.post '/v0/processing/pricing', (req, res, next) ->
  skuRunner.runPricingAlgorithm()
  res.json global.ee_status
  return

app.post '/v0/processing/cloudinary', (req, res, next) ->
  skuRunner.runCloudinary()
  res.json global.ee_status
  return

app.post '/v0/processing/tags', (req, res, next) ->
  skuRunner.runTags()
  res.json global.ee_status
  return

app.get '/v0/processing/status', (req, res, next) ->
  utils.setStatus()
  res.json global.ee_status
  return

app.use bodyParser.urlencoded({ extended: true })
app.use bodyParser.json()

app.use serveStatic(path.join __dirname, 'dist')

app.all '/*', (req, res, next) ->
  # Send index.html to support HTML5Mode
  res.sendFile 'index.html', root: path.join __dirname, 'dist'
  return

# app.use vhost('ee-admin.herokuapp.com', app)
# app.use vhost('localhost', app)
# app.use vhost('192.168.1.*', app)

app.listen process.env.PORT, ->
  console.log 'Frontend listening on port ' + process.env.PORT
  return
