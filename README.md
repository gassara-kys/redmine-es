# redmine-test

### 起動

- docker-composeコマンド

```bash
$ cd /path/to/dir/
$ git clone https://github.com/gassara-kys/redmine-test.git
$ docker-compose up -d
```

- 起動時にエラーが発生した場合
  - Elasticsearch起動時のメモリ消費調整
    - vm.max_map_countの値を調整
    - 詳細は https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker
  - mysqlのマウント先のパーミッションエラーが発生した場合
    - docker volume ls でDBにマウントされているディスクを確認 
    - docker volume inspect {dbvolume}でマウント先のパスを確認
    - chmod 777 {マウント先}

### 動作確認

localhostの部分はdockerホストのIPに読替え

- Redmine
  - http://localhost:3000/
- Kibana
  - http://localhost/

### サンプルデータをREDMINEに流す

あとで


### Redmineチケットの更新をElasticsearchに流す

- dockerが起動している状態で下記のスクリプトを実行

```bash
$ cd redmine-test/util
$ ./exec_redmine_es_script.sh
```

- cron登録する例

```bash
$ crontab -e

# 毎分起動
*/1 * * * * /path/to/dir/redmine-test/util/exec_redmine_es_script.sh
```


