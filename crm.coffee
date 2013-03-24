# create 'Case' objects in CRM when we see
# device failures
#
salesforce = require("node-salesforce")

cols = (name) ->
  sf = new salesforce.Connection()
  sf.login process.env.CRM_USERNAME, process.env.CRM_PASSWORD, (err, sub) ->
    sf.sobject(name).describe (err, meta) ->
      console.log field.name for field in meta.fields


decode = (code) ->
  switch parseInt(code)
   when 42 then 'Sensor Broken'

with_the_force = (cb) ->
  sf = new salesforce.Connection()
  sf.login process.env.CRM_USERNAME,
    process.env.CRM_PASSWORD,
    (err, user) -> cb err, sf

open_case = (data) ->
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
        console.log("success=#{ret.success} case_id=#{ret.id}")

exports.log_drain = (req, res) ->
  (open_case(line) if line.failure) for line in req.body
  res.send('OK')
