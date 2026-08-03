select
  assignment_id,
  student_id,
  room_id
from {{ ref('int_assignments_enhanced') }}
where
  (coalesce(wants_ac, false) and not coalesce(has_ac, false))
  or (coalesce(wants_dining, false) and not coalesce(has_dining, false))
  or (coalesce(wants_kitchen, false) and not coalesce(has_kitchen, false))
  or (
    coalesce(wants_private_bathroom, false)
    and not coalesce(has_private_bathroom, false)
  )
