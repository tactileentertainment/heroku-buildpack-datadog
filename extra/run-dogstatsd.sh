#!/bin/bash

if [[ $DISABLE_DATADOG_AGENT ]]; then
  echo "DISABLE_DATADOG_AGENT environment variable is set, not starting the agent."
  exit 0
fi

if [[ $DATADOG_API_KEY ]]; then
  sed -i -e "s/^.*api_key:.*$/api_key: ${DATADOG_API_KEY}/" /app/.apt/opt/datadog-agent/agent/datadog.conf
else
  echo "DATADOG_API_KEY environment variable not set. Run: heroku config:add DATADOG_API_KEY=<your API key>"
  exit 0
fi

if [[ $DATADOG_HOST_NAME ]]; then
  sed -i -e "s/^.*hostname:.*$/hostname: ${DATADOG_HOST_NAME}/" /app/.apt/opt/datadog-agent/agent/datadog.conf
elif [[ $HEROKU_APP_NAME ]]; then
  sed -i -e "s/^.*hostname:.*$/hostname: ${HEROKU_APP_NAME}/" /app/.apt/opt/datadog-agent/agent/datadog.conf
else
  echo "DATADOG_HOST_NAME nor HEROKU_APP_NAME environment variable set. Run: heroku apps:info|grep ===|cut -d' ' -f2"
  exit 0
fi

(
  # Load our library path first when starting up
  export LD_LIBRARY_PATH=/app/.apt/opt/datadog-agent/embedded/lib:$LD_LIBRARY_PATH
  mkdir -p /tmp/logs/datadog
  exec /app/.apt/opt/datadog-agent/embedded/bin/python /app/.apt/opt/datadog-agent/agent/dogstatsd.py start
)
