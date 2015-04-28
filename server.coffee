switch process.env.NODE_ENV
  when 'production'
    require 'newrelic'
  when 'test'
    process.env.PORT = 3333
  else
    process.env.NODE_ENV = 'development'
    process.env.PORT = 3000

express         = require 'express'
vhost           = require 'vhost'
morgan          = require 'morgan'
path            = require 'path'
serveStatic     = require 'serve-static'
bodyParser      = require 'body-parser'

# Parent app
app             = express()

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
  builder.use forceSsl
  app.use morgan 'common'
else
  app.use morgan 'dev'

app.use bodyParser.urlencoded({ extended: true })
app.use bodyParser.json()

app.use serveStatic(path.join __dirname, 'dist')
app.all '/*', (req, res, next) ->
  # Send builder.html to support HTML5Mode
  res.sendfile 'index.html', root: path.join __dirname, 'dist'
  return

app.use vhost('ee-admin.herokuapp.com', app)
app.use vhost('localhost', app)
app.use vhost('192.168.1.*', app)

app.listen process.env.PORT, ->
  console.log 'Frontend listening on port ' + process.env.PORT
  return
