{{ config(materialized='view') }}

with src as (
  select * from {{ source('housing_raw', 'raw_assignments') }}
)

select
  cast(student_id as int64) as student_id,
  cast(building_id as int64) as building_id,
  cast(room_number as int64) as room_number,

  concat(cast(building_id as string), '-', cast(room_number as string)) as room_id,

  cast(assigned_at as timestamp) as assigned_at,
  cast(_ingested_at as timestamp) as _ingested_at,

  -- Id útil para depurar/cargar incrementales
  to_hex(md5(concat(
    cast(student_id as string), '|',
    cast(building_id as string), '|',
    cast(room_number as string), '|',
    cast(coalesce(assigned_at, _ingested_at) as string)
  ))) as assignment_id
from src
where student_id is not null
  and building_id is not null
  and room_number is not null
