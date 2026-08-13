{{ config(materialized='view') }}

select
  date(assigned_at) as assignment_date,
  count(*) as assignments
from {{ ref('fct_student_assignments') }}
where assigned_at is not null
group by assignment_date
order by assignment_date
