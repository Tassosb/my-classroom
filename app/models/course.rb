class Course < ApplicationRecord
  belongs_to :user

  has_many :enrollments
  has_many :students, through: :enrollments, dependent: :destroy
end
