# create 'Case' objects in CRM when we see
# device failures
#
salesforce = require("node-salesforce")
redis      = require('./configure').createRedisClient()

RATE_LIMIT = parseInt(process.env.RATE_LIMIT || 60)

cols = (name) ->
  sf = new salesforce.Connection()
  sf.login process.env.CRM_USERNAME, process.env.CRM_PASSWORD, (err, sub) ->
    sf.sobject(name).describe (err, meta) ->
      console.log field.name for field in meta.fields

decode = (code) ->
  if message = process.env["CODE_#{code}"]
    message
  else
    'Sensor Failed'

with_the_force = (cb) ->
  sf = new salesforce.Connection()
  sf.login process.env.CRM_USERNAME,
    process.env.CRM_PASSWORD,
    (err, user) -> cb err, sf

rate_limit = (key, callback) ->
  redis.get key, (err, value) ->
    callback() unless value
    redis.setex key, RATE_LIMIT, (new Date()).getTime(), redis.print

open_case = (data) ->
  open_the_case = ->
    with_the_force (err, sf) ->
      console.log(err) if err
      sf.sobject('Case').create
        Type: data.type || 'Electrical'
        OwnerId: process.env.OWNER_ID || "005i0000000dHa7"
        Reason: decode(data.code)
        ContactId: process.env.CONTACT_ID || '003i0000004JYXi'
        Device_Id__c: data.device_id
        Product__c: "#{data.device_type || 'Virtual'} Thermostat"
        Sensor_Location__Latitude__s: data.lat || 42
        Sensor_Location__Longitude__s: data.long || 42
        Error_Code__c: data.code,
        (err, ret) ->
          console.log(err) if err
          console.log("success=#{ret.success} case_id=#{ret.id}") unless err
  key = "#{data.device_id}:#{data.code}"
  rate_limit(key, open_the_case)

exports.log_drain = (req, res) ->
  open_case(line) for line in req.body when line.failure
  res.send('OK')
