select *
from {{ ref('stg_rooms') }}
where num_beds <= 0
