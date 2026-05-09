{{ config(materialized='view') }}

with assignments as (
  select * from {{ ref('int_assignments_enhanced') }}
)

select
  assignment_id,
  student_id,
  student_name,
  wants_ac,
  wants_dining,
  wants_kitchen,
  wants_private_bathroom,
  room_id,
  building_id,
  room_number,
  num_beds,
  has_private_bathroom,
  has_kitchen,
  building_name,
  address,
  has_ac,
  has_dining,
  assigned_at,
  _ingested_at
from assignments
order by assigned_at desc
