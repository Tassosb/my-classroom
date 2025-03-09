class Course < ApplicationRecord
  belongs_to :user

  has_many :enrollments
  has_many :students, through: :enrollments, dependent: :destroy
  # assignments must be destroyed before topics due to foreign key constraint
  has_many :assignments, dependent: :destroy
  has_many :assignment_grades, through: :assignments
  has_many :topics, dependent: :destroy
  has_many :grade_categories, dependent: :destroy
end
