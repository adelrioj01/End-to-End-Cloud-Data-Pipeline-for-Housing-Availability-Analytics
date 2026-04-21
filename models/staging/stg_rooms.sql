{{ config(materialized='view') }}

with src as (
  select * from {{ source('housing_raw', 'raw_rooms') }}
)

select
  cast(building_id as int64) as building_id,
  cast(room_number as int64) as room_number,

  -- Clave estable para joins
  concat(cast(building_id as string), '-', cast(room_number as string)) as room_id,

  -- Normalizamos a "num_beds" para analytics
  cast(num_beds as int64) as num_beds,

  cast(private_bathrooms as bool) as has_private_bathroom,
  cast(has_kitchen as bool) as has_kitchen,

  cast(_ingested_at as timestamp) as _ingested_at
from src
where building_id is not null
  and room_number is not null
