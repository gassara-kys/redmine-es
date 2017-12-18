package main

import (
	"fmt"
	"log"
	"time"

	"github.com/jinzhu/gorm"
	"github.com/olivere/elastic"
)

const (
	dbName     = "garigari"
	dbUser     = "garigari"
	dbPass     = "garigari"
	dbProtocol = "tcp"
	dbHost     = "127.0.0.1"
	dbPort     = "3306"

	url = "http://elasticsearch:9200/"
)

func main() {
	// DB fetch

	// Elasticsearch put
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

func putEsData() {
	client, err := elastic.NewClient()
	if err != nil {
		log.Fatal(err)
	}

	bulkRequest := client.Bulk()

	// for loop start
	issue1 := Issue{
		ID:        "1",
		ProjectID: "1",
		ProjectNm: "Security_Event",
		TrackerID: "1",
		TrackerNm: "TEAM1",
		StatusID:  "1",
		StatusNm:  "STATUS1",
		CreatedOn: time.Now(),
		UpdatedOn: time.Now(),
	}
	index1Req := elastic.NewBulkIndexRequest().
		Index("201801").
		Type("issue").
		Id("1").
		Doc(issue1)

	bulkRequest = bulkRequest.Add(index1Req)
	// for loop end

	bulkResponse, err := bulkRequest.Do()
	if err != nil {
		log.Fatal(err)
	}
	failedResults := bulkResponse.Failed()
	if failedResults != nil {
		log.Printf("ES Bulk Request Failed: %v", failedResults)
	}

}
