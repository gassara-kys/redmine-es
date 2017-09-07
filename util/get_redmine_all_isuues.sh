#/bin/bash

DOCKER_HOST="192.168.99.100"
REDMINE_PORT="3000"
REDMINE_API_KEY="037af070d83f3002722f29f2d0f9303b7b38e440"
REDMINE_URL="http://$DOCKER_HOST:$REDMINE_PORT/issues.json?key=$REDMINE_API_KEY&limit=100&page="

total_count=$(curl -s -XGET $REDMINE_URL | jq '.total_count')
if ! [[ "$total_count" =~ ^[0-9]+$ ]] then
    echo "get redmine issues total_count failed... "
    exit 1
fi


pages=`expr $total_count / 100 + 1`

function get_issues() {
  response=$(curl -s -XGET $REDMINE_URL$1 | jq '.issues[] |{id:.id, tracker:.tracker.name, status:.status.name, category:.category.name, suject:.subject, updated_date:.updated_on, created_date:.created_on}')
  echo $response
}

for i in `seq 1 $total_count`
do
  get_issues $i
done
