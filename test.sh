curl -X POST --header 'Content-Type: application/logplex-1' -d "foo=bar" http://localhost:5000/logs
curl -X POST --header 'Content-Type: application/logplex-1' -d "failure=true code=42 device_id=1" http://localhost:5000/logs
