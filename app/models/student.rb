class Student < ApplicationRecord
  has_many :enrollments
  has_many :courses, through: :enrollments
  has_many :assignment_grades, dependent: :destroy

  def name
    "#{first_name} #{last_name}"
  end
end
