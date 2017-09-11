#/bin/bash
# ################################################################################
#   MySQL
# ################################################################################

# 接続情報
MYSQL_CLIENT_CONF=/usr/src/redmine/script/elasticsearch/client.conf
MYSQL_SCHEMA='redmine'

# ベースSQL
SQL_BASE_ISSUES="select id, project_id, tracker_id, subject, category_id, status_id, date_format(created_on, '%Y/%m/%dT%H:%i:%s') as created_on, date_format(updated_on, '%Y/%m/%dT%H:%i:%s') as updated_on from issues"

# 出力ファイル
POS_FILE=/usr/src/redmine/script/elasticsearch/issues.pos
OUT_FILE=/usr/src/redmine/script/elasticsearch/issues.json

function errorEcho()
{
    echo "[`date '+%Y/%m/%d %T'`] $1"
}

function updatePosFile() {
  echo $1 > $POS_FILE
}

# MySQL コマンドでSQL実行 -値を1つだけ取得
# argv : where区など
function outputSQLResult() {

  QUERY="$SQL_BASE_ISSUES $@"
  echo "mysql --defaults-extra-file=$MYSQL_CLIENT_CONF -h mysql --database=$MYSQL_SCHEMA -B -e \"$QUERY\""
  ResultCsv=$(mysql --defaults-extra-file=$MYSQL_CLIENT_CONF -h mysql --database=$MYSQL_SCHEMA -B -e "$QUERY" | sed -e 's/\t/,/g'| sed -e 's/\r/\n/g')
  ret=$?
  if [ $ret -gt 0 ];then
      errorEcho "SQL error($ret) : $Result"
      exit 1
  fi

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

    # カラム取得
    if [ $cnt -eq 1 ];then
      for col in ${VALUES[@]}; do
        KEYS=("${KEYS[@]}" $col)
      done
      continue
    fi

    # JSONコンバート
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


NOW=`date "+%Y/%m/%dT%H:%M:%S"`
POS_DATETIME=`cat $POS_FILE`
FILTER=" where "

if [ -z "$POS_DATETIME" ]; then
  FILTER=$FILTER" updated_on <= str_to_date('$NOW' ,'%Y/%m/%dT%H:%i:%s')"
else
  FILTER=$FILTER" updated_on <= str_to_date('$NOW' ,'%Y/%m/%dT%H:%i:%s')"
  FILTER=$FILTER" AND updated_on > str_to_date('$POS_DATETIME' ,'%Y/%m/%dT%H:%i:%s')"
fi

outputSQLResult $FILTER
updatePosFile $NOW