request = require 'request'
fs = require 'fs'

# helpers
rsapi = process.env.RS_API_KEY
rsagency = 'paac'
rsstop = 'P00750'

createEntry = (PhoneID, OriginalText) ->
  message = PhoneID + '\t' + OriginalText + '\t' + new Date().getTime() + '\n'
  fs.appendFile 'textlog.txt', message, (err) ->
    if err
      0
    else
      1

removeThinkBusFromText = (text) ->
  text.toLowerCase().replace(/thinkbus/, '').replace /^\s+|\s+$/g, ''

getBusCodeFromText = (text) ->
  busRegex = /(\d{2}[a-z]{1})/
  busCode = text.match busRegex
  if busCode
    busCode[0].toUpperCase()
  else
    0

getNextBusTimes = (cb) ->
  request "http://api.routeshout.com/v1/rs.stops.getTimes" + "?key=" + rsapi + "&agency=" + rsagency + "&stop=" + rsstop,
    (error, response, body) ->
      cb(JSON.parse body)

generateMessageFromBusCode = (busCode, info) ->
  #console.log info
  nextBusArray = info.filter (r) -> r.route_short_name == busCode
  #console.log nextBusArray
  times = (bus.arrival_time for bus in nextBusArray)
  #console.log times
  times = times.reduce (x, y) -> x + ', ' + y
  msg = busCode + ' is scheduled for: ' + times

generateMessageWithoutBusCode = (info) ->
  bussn = []
  nextBusArray = []
  nbus = []
  for bus in info
    if !(bus.route_short_name in bussn) && bussn.length < 3
      bussn.push bus.route_short_name
      nextBusArray.push bus
  for bus in nextBusArray
    nbus.push bus.route_short_name + ' @ ' + bus.arrival_time
  msg = nbus.reduce (x, y) -> x + ', ' + y
  "The next buses are " + msg

# end helpers

exports.index = (req, res) ->
  if req.query.PhoneId && req.query.OriginalText
    pid = req.query.PhoneId
    ot = req.query.OriginalText
    # log it
    createEntry pid, ot
    # parse text for bus
    busCode = getBusCodeFromText(removeThinkBusFromText ot)
    # generate response
    getNextBusTimes (info) ->
      busInfo = info.response
      if busCode != 0
        msg = generateMessageFromBusCode busCode, busInfo
      else
        msg = generateMessageWithoutBusCode busInfo
      res.send "<MsgmeKeywordResponse><Content><Message><![CDATA[#{msg}]]></Message></Content></MsgmeKeywordResponse>"
  else
    res.send "Sorry, you didn't send the right information :("

exports.live = (req, res) ->
  # display all current texts in the database
  # use socket io?
  res.send "Not yet working"
