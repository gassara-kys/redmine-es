package main

import (
	"time"
)

// Issue Redmine issues
type Issue struct {
	ID        string    `json:"id"`
	ProjectID string    `json:"project_id"`
	ProjectNm string    `json:"project_nm"`
	TrackerID string    `json:"tracker_id"`
	TrackerNm string    `json:"tracker_nm"`
	StatusID  string    `json:"status_id"`
	StatusNm  string    `json:"status_nm"`
	CreatedOn time.Time `json:"created_on"`
	UpdatedOn time.Time `json:"updated_on"`
}
