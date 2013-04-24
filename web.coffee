
###
Module dependencies.
###
async = require("async")
express = require("express")
http = require("http")
path = require("path")
logplex = require("./logplex")
routes  = require("./crm")
salesforce = require("node-salesforce")

app = express()

express.logger.format "method",     (req, res) -> req.method.toLowerCase()
express.logger.format "url",        (req, res) -> req.url.replace('"', "&quot")
express.logger.format "user-agent", (req, res) -> (req.headers["user-agent"] || "").replace('"', "")

app.configure "development", ->
  app.use express.errorHandler()
  app.use express.logger("dev")

app.configure 'production', ->
  app.use express.logger
    buffer: false
    format: "ns=\"mc.l2crm\" measure=\"http.:method\" source=\":url\" status=\":status\" elapsed=\":response-time\" from=\":remote-addr\" agent=\":user-agent\""

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.use express.favicon()
  app.use express.methodOverride()
  # LogPlex body parser
  app.use logplex()
  app.use express.bodyParser()
  app.use app.router

# Connect Routes
app.post "/logs", routes.log_drain
app.get  "/", (req, res) -> res.send("NOTHING TO SEE HERE")

reset_auth = express.basicAuth("heroku", process.env.HTTP_PASSWORD)

app.get "/reset", reset_auth, (req, res) ->
  sf = new salesforce.Connection()
  sf.login process.env.CRM_USERNAME, process.env.CRM_PASSWORD, (err, user) ->
    async.parallel
      case: (aacb) ->
        sf.query "SELECT Id FROM Case", (err, result) ->
          async.parallel (result.records.map (record) ->
            (acb) ->
              sf.sobject("Case").destroy record.Id, acb),
            aacb
      chatter: (aacb) ->
        sf.query "SELECT Id FROM FeedItem", (err, result) ->
          async.parallel (result.records.map (record) ->
            (acb) ->
              sf.sobject("FeedItem").destroy record.Id, acb),
          aacb
      (err, results) ->
        console.log "err", err
        console.log "results", results
        res.send "ok"


# Listen for Requests
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
