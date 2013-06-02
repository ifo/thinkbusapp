
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

app.get "/", routes.index
app.get "/sms", routes.sms
app.post "/sms", routes.smsp

# because the sms api is sent to /
#app.get "/index", routes.index

# route shout section
app.get "/rs/agencies", routes.getAgencies
app.get "/rs/stops", routes.getStops
app.get "/rs/shout", routes.shout
app.get "/rs/nextbus/:id?", routes.nextbus

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
