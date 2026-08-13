{{ config(tags=['type_validation']) }}

with expected as (
  select 'stg_assignments' as table_name, 'student_id' as column_name, 'INT64' as data_type union all
  select 'stg_assignments', 'building_id', 'INT64' union all
  select 'stg_assignments', 'room_number', 'STRING' union all
  select 'stg_assignments', 'assigned_at', 'TIMESTAMP' union all
  select 'stg_rooms', 'building_id', 'INT64' union all
  select 'stg_rooms', 'room_number', 'STRING' union all
  select 'stg_rooms', 'num_beds', 'INT64' union all
  select 'stg_rooms', 'has_private_bathroom', 'BOOL' union all
  select 'stg_rooms', 'has_kitchen', 'BOOL' union all
  select 'stg_students', 'student_id', 'INT64' union all
  select 'stg_buildings', 'building_id', 'INT64'
),

actual as (
  select table_name, column_name, data_type
  from `{{ env_var('GCP_PROJECT_ID') }}.{{ env_var('BQ_DATASET_ANALYTICS') }}.INFORMATION_SCHEMA.COLUMNS`
  where table_name in ('stg_assignments', 'stg_rooms', 'stg_students', 'stg_buildings')
)

select
  expected.table_name,
  expected.column_name,
  expected.data_type as expected_type,
  actual.data_type as actual_type
from expected
left join actual using (table_name, column_name)
where actual.column_name is null
   or actual.data_type != expected.data_type
