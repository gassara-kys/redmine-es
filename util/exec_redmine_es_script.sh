#!/bin/bash

REDMINE_CONTAINER_ID=`docker ps --filter NAME=redmine -q`

if [ -n "$REDMINE_CONTAINER_ID" ]; then
  docker exec -d $REDMINE_CONTAINER_ID /bin/bash /usr/src/redmine/script/elasticsearch/put_redmine_issues.sh
fi

