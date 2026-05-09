{{ config(materialized='table') }}

with rooms as (
  select * from {{ ref('stg_rooms') }}
),

buildings as (
  select * from {{ ref('stg_buildings') }}
),

assignments as (
  select * from {{ ref('stg_assignments') }}
)

select
  r.building_id,
  b.building_name,
  b.address,
  r.room_id,
  r.room_number,
  r.num_beds,
  r.has_private_bathroom,
  r.has_kitchen,
  count(distinct a.student_id) as current_occupancy,
  r.num_beds - count(distinct a.student_id) as available_beds,
  round(
    (count(distinct a.student_id) / r.num_beds) * 100, 2
  ) as occupancy_rate
from rooms r
left join buildings b on r.building_id = b.building_id
left join assignments a on r.room_id = a.room_id
group by
  r.building_id,
  b.building_name,
  b.address,
  r.room_id,
  r.room_number,
  r.num_beds,
  r.has_private_bathroom,
  r.has_kitchen
