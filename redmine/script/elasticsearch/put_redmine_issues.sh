#/bin/bash
# ################################################################################
#  Const
# ################################################################################
# 接続情報
MYSQL_CLIENT_CONF=/usr/src/redmine/script/elasticsearch/client.conf
MYSQL_SCHEMA='redmine'
ES_HOST='elasticsearch'
ES_PORT='9200'

# ベースSQL
SQL_BASE_ISSUES="select id, project_id, tracker_id, subject, category_id, status_id, date_format(created_on, '%Y/%m/%dT%H:%i:%s') as created_on, date_format(updated_on, '%Y/%m/%dT%H:%i:%s') as updated_on from issues"

# ファイル
SCHEMA_FILE=/usr/src/redmine/script/elasticsearch/es_issues_schema.json
POS_FILE=/usr/src/redmine/script/elasticsearch/issues.pos
OUT_FILE=/usr/src/redmine/script/elasticsearch/issues.json


# ################################################################################
#  function
# ################################################################################
function echoLog() {
  echo -e "[`date '+%Y/%m/%d %T'`] $1"
}

function updatePosFile() {
  echo $1 > $POS_FILE
}

# create elasticsearch index when not created yet.
function createIndex() {

  STATUS_CODE=`curl -LI -o /dev/null -w '%{http_code}' -s http://$ES_HOST:$ES_PORT/$1`
  if [ ${STATUS_CODE} != "200" ]; then
    echoLog "create index http://$ES_HOST:$ES_PORT/$1"
    curl -XPUT http://$ES_HOST:$ES_PORT/$1/
    curl -XPUT http://$ES_HOST:$ES_PORT/$1/_mapping/issues -d @$SCHEMA_FILE
  fi
}

# MySQL select
# argv : where
function outputSQLResult() {

  # clear file
  rm $OUT_FILE; touch $OUT_FILE

  # mysql select
  QUERY="$SQL_BASE_ISSUES $@"
  ResultCsv=$(mysql --defaults-extra-file=$MYSQL_CLIENT_CONF -h mysql --default-character-set=utf8 --database=$MYSQL_SCHEMA -B -e "$QUERY" | sed -e 's/\t/,/g'| sed -e 's/\r/\n/g')

  ret=$?
  if [ $ret -gt 0 ];then
      echoLog "SQL error($ret) : $Result"
      exit 1
  fi

  # output file
  echo $ResultCsv
  cnt=0
  KEYS=()
  for record in ${ResultCsv[@]}; do

    let cnt++

    # split
    IFS_ORIGINAL="$IFS"
    IFS=,
    VALUES=($record)
    IFS="$IFS_ORIGINAL"

    # get columns
    if [ $cnt -eq 1 ];then
      for col in ${VALUES[@]}; do
        KEYS=("${KEYS[@]}" $col)
      done
      continue
    fi

    # JSON format convert
    json_record="{"
    for ((i = 0; i < ${#VALUES[@]}; i++)) {
      if [ $i -gt 0 ];then
        json_record=$json_record", "
      fi
      json_record=$json_record'"'
      json_record=$json_record"${KEYS[i]}"
      json_record=$json_record'"'
      json_record=$json_record" : "
      json_record=$json_record'"'
      json_record=$json_record"${VALUES[i]}"
      json_record=$json_record'"'
    }
    json_record=$json_record"}"

    echo $json_record >> $OUT_FILE
  done
}


function putElasticsearch() {
  ID_PRE=`date "+%Y%m%d%H%M%S"`
  idx=0

  TEMP_FILE=`dirname $0`/tmp.json
  cat $OUT_FILE | while read line
  do
    let idx++
    EVENT_ID=$ID_PRE$idx
    echo $line > $TEMP_FILE
    echoLog "target:$ES_HOST:$ES_PORT/$1/issues/ ,_id : $EVENT_ID, _source : `cat $TEMP_FILE`"
    curl -s -XPUT http://$ES_HOST:$ES_PORT/$1/issues/$EVENT_ID --data @$TEMP_FILE
  done

  rm $TEMP_FILE
}

# ################################################################################
#   main
# ################################################################################
# set values
YYYYMM=`date  "+%Y%m"`
ES_INDEX="redmine-$YYYYMM"
NOW=`date "+%Y/%m/%dT%H:%M:%S"`
POS_DATETIME=`cat $POS_FILE`
FILTER=" where "
if [ -z "$POS_DATETIME" ]; then
  FILTER=$FILTER" updated_on <= str_to_date('$NOW' ,'%Y/%m/%dT%H:%i:%s')"
else
  FILTER=$FILTER" updated_on <= str_to_date('$NOW' ,'%Y/%m/%dT%H:%i:%s')"
  FILTER=$FILTER" AND updated_on > str_to_date('$POS_DATETIME' ,'%Y/%m/%dT%H:%i:%s')"
fi

# exec functions
createIndex $ES_INDEX
outputSQLResult $FILTER
if [ $? -ne 0 ]; then echo "DB select Error";exit 1; fi

putElasticsearch $ES_INDEX
updatePosFile $NOW
