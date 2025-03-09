class AssignmentGrade < ApplicationRecord
  belongs_to :assignment
  belongs_to :student
end
