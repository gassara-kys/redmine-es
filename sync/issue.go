package main

import (
	"time"
)

// Issue Redmine issues
type Issue struct {
	IssueID    string    `json:"issue_id"`
	ProjectID  string    `json:"project_id"`
	ProjectNm  string    `json:"project_nm"`
	TrackerID  string    `json:"tracker_id"`
	TrackerNm  string    `json:"tracker_nm"`
	Subject    string    `json:"subject"`
	CategoryID string    `json:"category_id"`
	CategoryNm string    `json:"category_nm"`
	StatusID   string    `json:"status_id"`
	StatusNm   string    `json:"status_nm"`
	PriorityID string    `json:"priority_id"`
	AuthorID   string    `json:"author_id"`
	AuthorNm   string    `json:"author_nm"`
	CreatedOn  time.Time `json:"created_on"`
	UpdatedOn  time.Time `json:"updated_on"`
	ClosedOn   time.Time `json:"closed_on"`
	Score      int `json:"score"`
}
