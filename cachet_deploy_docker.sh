#!/bin/bash

echo "Building cachet docker image..."
docker-compose build

echo "Starting docker container to generate APP_KEY..."
docker-compose up --abort-on-container-exit > docker_output.log 2>&1

APP_KEY=$(cat docker_output.log | grep APP_KEY | cut -d "'" -f 2)

echo "Setting APP_KEY in docker-compose.yml..."
sed -i "s|APP_KEY=\${APP_KEY:-null}|$APP_KEY|" docker-compose.yml

echo "Starting docker containers in the background..."
docker-compose up -d

WAIT_ROUND=0
MAX_WAIT_ROUNDS=12
DOCKER_UP=0

echo "Polling for docker containers to start..."
while [[ $WAIT_ROUND -lt $MAX_WAIT_ROUNDS ]] && [[ $DOCKER_UP -eq 0 ]]
do
  RES=$(docker-compose ps | grep cachet_1 | grep Up)
    echo $RES
    docker-compose ps
    docker-compose images
  if test -n "$RES"; then
      DOCKER_UP=1
    else
      WAIT_ROUND=$((WAIT_ROUND+1))
        if test $WAIT_ROUND -eq $MAX_WAIT_ROUNDS; then
          echo "Docker containers did not start as expected in 120 seconds, aborting..."
            exit 1
        fi
      sleep 10
    fi
done

echo "Waiting 10 seconds for API service to become available..."
sleep 10

echo "Verifying API service is online..."
API_PING_RESPONSE=$(curl -s http://localhost:7999/api/v1/ping)
API_PING_RESPONSE_DATA=$(echo $API_PING_RESPONSE | jq '.[]')

if test "$API_PING_RESPONSE_DATA" = '"Pong!"'; then
  echo "The API responded to ping request correctly."
else
  echo "Could not reach API. Response to ping: $API_PING_RESPONSE"
    echo "Job is halting."
    exit 1
fi

echo "Verifying UI is online..."
UI_RESPONSE_CODE=$(curl -o /dev/null -s -I -w '%{http_code}\n' http://localhost:7999/setup)
if test "$UI_RESPONSE_CODE" -eq 200; then
  echo "The UI returned HTTP 200."
else
  echo "The UI returned code $UI_RESPONSE_CODE instead of 200"
    echo "Job is halting."
    exit 1
fi

echo "Deployment complete."
