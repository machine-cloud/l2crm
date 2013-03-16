
###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
logplex = require("./logplex")
routes  = require("./crm")
app = express()

express.logger.format "method",     (req, res) -> req.method.toLowerCase()
express.logger.format "url",        (req, res) -> req.url.replace('"', "&quot")
express.logger.format "user-agent", (req, res) -> (req.headers["user-agent"] || "").replace('"', "")

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.use express.favicon()
  app.use express.methodOverride()
  # LogPlex body parser
  app.use logplex()
  app.use express.bodyParser()
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler()
  app.use express.logger("dev")

app.configure 'production', ->
  app.use express.logger
    buffer: false
    format: "ns=\"mc.errortrends\" measure=\"http.:method\" source=\":url\" status=\":status\" elapsed=\":response-time\" from=\":remote-addr\" agent=\":user-agent\""

# Connect Routes
app.post "/logs", routes.log_drain
app.get  "/", (req, res) -> res.send("NOTHING TO SEE HERE")

# Listen for Requests
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
