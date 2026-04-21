{{ config(materialized='view') }}

with room_occupancy as (
  select * from {{ ref('int_room_occupancy') }}
)

select
  building_id,
  building_name,
  address,
  count(distinct room_id) as total_rooms,
  sum(num_beds) as total_beds,
  sum(current_occupancy) as total_students,
  sum(available_beds) as total_available_beds,
  round(
    (sum(current_occupancy) / sum(num_beds)) * 100, 2
  ) as building_occupancy_rate,
  sum(case when has_private_bathroom then 1 else 0 end) as rooms_with_private_bathroom,
  sum(case when has_kitchen then 1 else 0 end) as rooms_with_kitchen
from room_occupancy
group by
  building_id,
  building_name,
  address
order by building_occupancy_rate desc
