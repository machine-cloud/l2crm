# create 'Case' objects in CRM when we see
# device failures
#
#

salesforce = require("node-salesforce")

with_the_force = (cb) ->
  sf = new salesforce.Connection()
  sf.login process.env.CRM_USERNAME,
    process.env.CRM_PASSWORD,
    (err, user) -> cb err, sf

open_case = (data) ->
  with_the_force (err, sf) ->
    console.log(err) if err
    sf.sobject('Case').create
      Type: 'Electrical'
      Reason: 'Breakdown'
      Product__c: 'ThermoStat'
      Sensor_Location__c: data.location || 'Osaka, Japan',
      Error_Code__c: data.code,
      (err, ret) ->
        console.log(err) if err
        console.log(ret)

exports.log_drain = (req, res) ->
  (open_case(line) if line.failure) for line in req.body
  res.send('OK')
