# redmine-es

## 目的

ここでは以下のようなことを実現しようとしています。
- チケット管理システムRedmine構築
- チケット更新情報をElasticserchに流す
- それをKibanaで見る
- という仕組みをDockerでやる
- ユースケースイメージ
```
User（チケット更新）
    ===> REDMINE 
    ===> (redmine-sync) ※go app
    ===> Elasticsearch
    ===> Kibana
    ===> User（集計／モニタリング）
```

## 準備

- docker
- docker-compose

### Ubuntuにdocker-ceインストールの例 ※詳細は公式を

```bash
$ sudo -s
$ apt-get -y install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ apt-get update
$ apt-get -y install docker-ce
```

## 起動

### RedmineとElasticsearch

- docker-composeコマンド

```bash
$ git clone https://github.com/gassara-kys/redmine-es.git
$ cd redmine-es
$ docker-compose build --no-cache
$ sysctl -w vm.max_map_count=262144 #Elasticsearch起動時のメモリ消費調整(vm.max_map_count)
$ source util/env.sample.sh
$ docker-compose up -d
```


### 動作確認

localhostの部分はdockerホストのIPに読み替え

- Redmine
  - http://localhost/
- Kibana
  - http://localhost:5601/



### Redmineチケットの更新をElasticsearchに流す

- Docker run

```bash
$ cd sync/
$ docker build -t redmine-sync:latest .
$ docker run --rm --name redmine-sync \
    -e DB_HOST={dockerホストのIP  or DNS} \ 
    -e DB_PORT=3306 \
    -e DB_NAME=redmine \
    -e DB_USER=redmine \
    -e DB_PASS=password \
    -e ES_URL="http://{dockerホストのIP or DNS}:9200" \
    redmine-sync:latest
```

- Set Cron

```bash
$ crontab -l > ~/crontab  #別ファイル編集
$ vi ~/crontab
# 以下を追加
DB_HOST={dockerホストのIP or DNS} 
DB_PORT=3306 
DB_NAME=redmine
DB_USER=redmine
DB_PASS=password
ES_URL="http://localhost:9200"  # dockerホスト

*/1 * * * * /usr/bin/docker run --rm --name redmine-sync -e DB_HOST=${DB_HOST} -e DB_PORT=${DB_PORT} -e DB_NAME=${DB_NAME} -e DB_USER=${DB_USER} -e DB_PASS=${DB_PASS} -e ES_URL=${ES_URL} redmine-sync:latest 2>&1 | logger -t redmine-sync

$ crontab < ~/crontab   # 戻し
```

- cron log

```bash
# logger の出力先にログが出る
$ tail -f /var/log/syslog
```

### その他

- redmine syncの依存関係

```bash
$ go get -v github.com/jinzhu/gorm
$ go get -v github.com/go-sql-driver/mysql
$ go get -v github.com/olivere/elastic
```
