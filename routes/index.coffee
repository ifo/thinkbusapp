request = require 'request'

#
# * GET home page.
# 
exports.index = (req, res) ->
  res.render "index",
    title: "ThinkBus"

exports.sms = (req, res) ->
  msg = "the message" #req.query.msg
  if req.query.msg
    msg = req.query.msg
  res.render "sms",
    message: msg

# expects 2 post variables, OriginalText and PhoneID
exports.smsp = (req, res) ->
  console.log req.body
  txt = req.body.OriginalText
  number = req.body.PhoneID
  res.render "phone",
    phone: number
    text: txt


# route shout section
rsapi = process.env.RS_API_KEY
rsagency = 'paac'
rsstop = 'P00750'

# allegheny is "paac"
exports.getAgencies = (req, res) ->
  request "http://api.routeshout.com/v1/rs.agencies.getList" + "?key=" + rsapi,
    (error, response, body) ->
      console.log body
      res.send body

exports.getStops = (req, res) ->
  request "http://api.routeshout.com/v1/rs.stops.getList" + "?key=" + rsapi + "&agency=" + rsagency,
    (error, response, body) ->
      console.log body
      res.send body

exports.shout = (req, res) ->
  request "http://api.routeshout.com/v1/rs.stops.getTimes" + "?key=" + rsapi + "&agency=" + rsagency + "&stop=" + rsstop,
    (error, response, body) ->
      console.log body
      res.send JSON.parse(body).response

exports.nextbus = (req, res) ->
  busid = req.params.id || 0
  request "http://api.routeshout.com/v1/rs.stops.getTimes" + "?key=" + rsapi + "&agency=" + rsagency + "&stop=" + rsstop,
    (error, response, body) ->
      body = JSON.parse(body)
      if busid != 0
        nbusarray = body.response.filter (r) -> r.route_short_name == busid
        ###
        for bus in body.response
          if bus.route_short_name == busid
            nbus = bus
        ###
      if !nbusarray
        nbusarray = body.response
      times = (bus.arrival_time for bus in nbusarray)
      buses = (bus.route_short_name for bus in nbusarray)
      nbus = JSON.stringify nbusarray
      #times = JSON.stringify times
      times = times.reduce (x, y) -> x + ", " + y
      times = busid + " scheduled for: " + times
      #nbus = JSON.stringify(nbus)
      res.render "nextbus",
        title: "Next Bus"
        nextbus: nbus
        times: times
        buses: buses
