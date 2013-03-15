#! /usr/bin/env bash

if [ "$1" = "" ]
then
  HOST=http://localhost:5000
else
  HOST=$1
fi

echo "using $HOST"
curl -X POST --header 'Content-Type: application/logplex-1' -d "foo=bar" $HOST/logs
curl -X POST --header 'Content-Type: application/logplex-1' -d "failure=true code=42 device_id=1" $HOST/logs
