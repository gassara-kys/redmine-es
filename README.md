# redmine-test

### RedmineAPIから情報取得

```bash
curl -s -XGET http://192.168.99.100:3000/projects/security-contest/issues.json \
| jq '.issues[] | {id : .id, tracker : .tracker.name, status: .status.name, category: .category.name, suject : .subject, updated_date: .updated_on, created_date:.created_on }| select(.updated_date > "2017-08-31T03:00:00Z")'

```
