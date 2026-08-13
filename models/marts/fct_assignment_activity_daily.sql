{{ config(materialized='view') }}

with assignments as (
  select
    date(assigned_at) as assignment_date,
    student_id,
    assignment_id
  from {{ ref('int_assignments_enhanced') }}
  where assigned_at is not null
)

select
  assignment_date,
  count(distinct student_id) as assigned_students,
  count(distinct assignment_id) as assignment_count
from assignments
group by assignment_date
order by assignment_date
