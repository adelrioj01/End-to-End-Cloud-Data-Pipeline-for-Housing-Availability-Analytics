{{ config(materialized='view') }}

with src as (
  select * from {{ source('housing_raw', 'raw_buildings') }}
)

select
  cast(building_id as int64) as building_id,
  nullif(trim(name), '') as building_name,
  nullif(trim(address), '') as address,

  cast(has_ac as bool) as has_ac,
  cast(has_dining as bool) as has_dining,

  cast(_ingested_at as timestamp) as _ingested_at
from src
where building_id is not null
