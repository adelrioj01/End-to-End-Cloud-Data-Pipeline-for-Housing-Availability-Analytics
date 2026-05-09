{{ config(materialized='table') }}

with students as (
  select * from {{ ref('stg_students') }}
),

assignments as (
  select * from {{ ref('stg_assignments') }}
),

rooms as (
  select * from {{ ref('stg_rooms') }}
),

buildings as (
  select * from {{ ref('stg_buildings') }}
)

select
  a.assignment_id,
  a.student_id,
  s.student_name,
  s.wants_ac,
  s.wants_dining,
  s.wants_kitchen,
  s.wants_private_bathroom,
  a.room_id,
  a.building_id,
  a.room_number,
  r.num_beds,
  r.has_private_bathroom,
  r.has_kitchen,
  b.building_name,
  b.address,
  b.has_ac,
  b.has_dining,
  a.assigned_at,
  a._ingested_at
from assignments a
left join students s on a.student_id = s.student_id
left join rooms r on a.room_id = r.room_id
left join buildings b on a.building_id = b.building_id
