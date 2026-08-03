select *
from {{ ref('int_room_occupancy') }}
where available_beds < 0
