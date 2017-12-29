package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
	"github.com/olivere/elastic"
)

const (
	dbHost     = os.GetENV("DB_HOST") // dev-redmine-es01.in.ssg.isca.jp
	dbPort     = os.GetENV("DB_PORT") // "3306"
	dbName     = os.GetENV("DB_NAME") // "redmine"
	dbUser     = os.GetENV("DB_USER") // "root"
	dbPass     = os.GetENV("DB_PASS") // "password"
	dbProtocol = "tcp"

	url = os.GetENV("ES_URL") // "http://dev-redmine-es01.in.ssg.isca.jp:9200"
)

func main() {
	// DB fetch
	db := getDB()
	defer db.Close()
	issues := getIssues(db)
	for idx, data := range *issues {
		log.Printf("issus[%d]: %v", idx, data)
	}

	// Elasticsearch put
	putEsData(issues)
}

func getDB() *gorm.DB {
	db, err := gorm.Open(
		"mysql",
		fmt.Sprintf(
			"%s:%s@%s([%s]:%s)/%s?parseTime=true",
			dbUser, dbPass, dbProtocol,
			dbHost, dbPort, dbName,
		),
	)
	if err != nil {
		log.Fatal(err)
	}
	db.DB()
	db.LogMode(true)
	return db
}

func getIssues(db *gorm.DB) *[]Issue {

	// [予定工数]のフィールドを無理やりですがスコアにしています
	query := `
select 
	i.id          as issue_id,
	i.project_id  as project_id,
	p.name        as project_nm, 
	i.tracker_id  as tracker_id,
	t.name        as tracker_nm, 
	i.subject     as subject,
	i.category_id as category_id,
	ic.name       as category_nm,
	i.status_id   as status_id,
	ists.name     as status_nm,
	i.priority_id as priority_id,
	i.author_id   as author_id,
	u.login       as author_nm,
	i.created_on  as created_on,
	i.updated_on  as updated_on,
	i.closed_on   as closed_on, 
    i.estimated_hours as score 
from
	issues i
	left outer join trackers t on t.id=i.tracker_id
	left outer join projects p on p.id=i.project_id
	left outer join issue_categories ic on ic.project_id=i.project_id and ic.id=i.category_id
	left outer join issue_statuses ists on ists.id=i.status_id
	left outer join users u on u.id=i.author_id 
order by 
	i.id
`
	var issues []Issue
	db.Raw(query).Scan(&issues)
	return &issues
}

func putEsData(issues *[]Issue) {
	client, err := elastic.NewClient(
		elastic.SetSniff(false),
		elastic.SetURL(url),
	)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Stop()

	bulkRequest := client.Bulk()
	for _, issue := range *issues {
		index1Req := elastic.NewBulkIndexRequest().
			Index("201801").
			Type("issues").
			Id(issue.IssueID).
			Doc(issue)
		bulkRequest = bulkRequest.Add(index1Req)
	}

	bulkResponse, err := bulkRequest.Do(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	failedResults := bulkResponse.Failed()
	if failedResults != nil {
		log.Printf("ES Bulk Request Failed: %v", failedResults)
	}

}
