-- Until assignment history is modeled, every row is treated as active.
select
  student_id,
  count(*) as assignment_count
from {{ ref('stg_assignments') }}
group by student_id
having count(*) > 1
