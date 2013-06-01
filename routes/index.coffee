
#
# * GET home page.
# 
exports.index = (req, res) ->
  res.render "index",
    title: "Express"

exports.sms = (req, res) ->
  msg = "the message" #req.query.msg
  if req.query.msg
    msg = req.query.msg
  res.render "sms",
    message: msg

exports.smsp = (req, res) ->
  console.log req.body
  txt = req.body.OriginalText
  number = req.body.PhoneID
  res.render "phone",
    phone: number
    text: txt
