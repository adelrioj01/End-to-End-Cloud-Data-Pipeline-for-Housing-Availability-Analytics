{{ config(materialized='view') }}

with src as (
  select * from {{ source('housing_raw', 'raw_students') }}
)

select
  cast(student_id as int64) as student_id,
  nullif(trim(name), '') as student_name,

  cast(wants_ac as bool) as wants_ac,
  cast(wants_dining as bool) as wants_dining,
  cast(wants_kitchen as bool) as wants_kitchen,
  cast(wants_private_bathroom as bool) as wants_private_bathroom,

  cast(_ingested_at as timestamp) as _ingested_at
from src
where student_id is not null
