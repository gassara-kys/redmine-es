#!/bin/bash
mkdir -p ./bin
go build -o ./bin/sync-redmine
chmod +x ./bin/sync-redmine
./bin/sync-redmine
