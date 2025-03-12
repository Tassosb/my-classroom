class Assignment < ApplicationRecord
  belongs_to :course
  belongs_to :topic, optional: true
  belongs_to :grade_category, optional: true

  has_many :assignment_grades, dependent: :destroy
end
