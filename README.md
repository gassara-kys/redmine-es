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

### Ubuntuの例

```bash
$ apt-get update
$ apt-get install docker.io
$ apt install docker-compose
```

## 起動

### RedmineとElasticsearch

- docker-composeコマンド

```bash
$ git clone https://github.com/gassara-kys/redmine-es.git
$ cd redmine-es
$ docker-compose build --no-cache
$ docker-compose up -d
```

- 起動時にエラーが発生した場合
  - Elasticsearch起動時のメモリ消費調整
  - vm.max_map_count
```bash
# docker hostにsshして...
$ sudo -s
$ sysctl -w vm.max_map_count=262144
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
$ docker build -t redmine-sync:latest .
$ docker run --rm --name redmine-sync \
    -e DB_HOST=localhost \
    -e DB_PORT=3306 \
    -e DB_NAME=redmine \
    -e DB_USER=redmine \
    -e DB_PASS=password \
    -e ES_URL="http://localhost:9200" \
    redmine-sync:latest
```

- Set Cron

```bash
$ crontab -l > ~/crontab  #別ファイル編集
$ vi ~/crontab
# 以下を追加
DB_HOST=localhost
DB_PORT=3306 
DB_NAME=redmine
DB_USER=redmine
DB_PASS=password
ES_URL="http://localhost:9200"

*/1 * * * * /usr/local/bin/docker run --rm --name redmine-sync -e DB_HOST=${DB_HOST} -e DB_PORT=${DB_PORT} -e DB_NAME=${DB_NAME} -e DB_USER=${DB_USER} -e DB_PASS=${DB_PASS} -e ES_URL=${ES_URL} redmine-sync:latest 2>&1 | logger -t redmine-sync

$ crontab < ~/crontab   # 戻し
```

### その他

- redmine syncの依存関係

```bash
$ go get -v github.com/jinzhu/gorm
$ go get -v github.com/go-sql-driver/mysql
$ go get -v github.com/olivere/elastic
```
