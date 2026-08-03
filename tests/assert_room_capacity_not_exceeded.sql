select
  r.room_id,
  r.num_beds,
  count(distinct a.student_id) as current_occupancy
from {{ ref('stg_rooms') }} r
left join {{ ref('stg_assignments') }} a
  on r.room_id = a.room_id
group by
  r.room_id,
  r.num_beds
having current_occupancy > r.num_beds
