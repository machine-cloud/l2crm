var redis   = require('redis');

exports.createRedisClient = function(){
  var redis_client = null;

  var redis_url = process.env[process.env.REDIS_NAME || 'REDISGREEN_URL'];

  //Setup Redis
  if (redis_url) {
    var rtg   = require("url").parse(redis_url);
    redis_client = redis.createClient(rtg.port, rtg.hostname);
    if (rtg.auth) {
      var redis_password = rtg.auth.split(":")[1]
    }
  } else {
    redis_client = redis.createClient();
  }

  redis_client.retry_backoff = 1.0;
  redis_client.retry_delay = 100;
  redis_client.max_attempts = 1000;

  redis_client.on("error", function (err) {
    console.log("Redis Error " + err);
  });

  if(redis_password){
    console.log("method=auth-redis");
    redis_client.auth(redis_password);
  }
  return redis_client
}

