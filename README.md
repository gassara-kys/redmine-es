# redmine-test

### RedmineAPIから情報取得

```bash
curl -s -XGET http://redmine:3000/issues.json \
| jq '.issues[] | {id : .id, tracker : .tracker.name, status: .status.name, category: .category.name, suject : .subject, updated_date: .updated_on, created_date:.created_on }| select(.updated_date > "2017-08-31T03:00:00Z")'

```
