select 
  i.id          as issue_id,
  i.tracker_id  as tracker_id,
  t.name        as tracker_nm, 
  i.project_id  as project_id,
  p.name        as project_nm, 
  i.subject     as subject,
  i.category_id as category_id,
  ic.name       as category_nm,
  i.status_id   as status_id,
  ists.name     as status_nm,
  i.created_on  as created_on,
  i.updated_on  as updated_on,
  i.closed_on   as closed_on
from
  issues i
  left outer join trackers t on t.id=i.tracker_id
  left outer join projects p on p.id=i.project_id
  left outer join issue_categories ic on ic.project_id=i.project_id
  left outer join issue_statuses ists on ists.id=i.status_id
;