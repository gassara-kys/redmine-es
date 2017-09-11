#/bin/bash

USER="root"
HOST="localhost"

# imposrt
mysql -u $USER -h $HOST -t redmine < ./redmine_sample.sql

# exposrt
# mysqldump -u root -p -c -t -l redmine --add-drop-table  > ./redmine_sample.sql
