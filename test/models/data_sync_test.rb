require "test_helper"

class DataSyncTest < ActiveSupport::TestCase
  test "Helper#sync_data!" do
    user = User.create!(uuid: "abcd", email_address: "t@b.org", password_digest: "password")

    data_from_google = {
      courses_attrs: [
        {
          google_id: "123",
          name: "Precalculus",
          students_attrs: [
            {
              google_id: "4321",
              first_name: "Harry",
              last_name: "Potter"
            }
          ],
          topics_attrs: [
            {
              google_id: "123",
              name: "Sorcery"
            }
          ],
          grade_categories_attrs: [
            {
              google_id: "234",
              name: "Homework",
              weight: 10
            }
          ],
          assignments_attrs: [
            {
              google_id: "789",
              name: "Exam 1",
              topic_google_id: "123",
              max_points: 100,
              due_on: "2025-02-01",
              grade_category_google_id: "234",
              assignment_grades_attrs: [
                {
                  google_id: "234",
                  draft_grade: nil,
                  returned_grade: 95,
                  student_google_id: "4321"
                }
              ]
            }
          ]
        },
        {
          google_id: "456",
          name: "STAM",
          students_attrs: [
            {
              google_id: "4321",
              first_name: "Harry",
              last_name: "Potter"
            }
          ],
          topics_attrs: [],
          assignments_attrs: [],
          grade_categories_attrs: []
        }
      ]
    }

    DataSync::Helper.sync_data!(user, data_from_google)

    assert_equal 2, user.courses.count
    assert_equal 1, user.students.count

    precal = user.courses.first
    assert_equal "123", precal.google_id
    assert_equal "Precalculus", precal.name
    assert_equal 1, precal.students.count

    harry = precal.students.first
    assert_equal "4321", harry.google_id
    assert_equal "Harry", harry.first_name
    assert_equal "Potter", harry.last_name

    assert_equal 1, precal.assignments.count
    precal_exam = precal.assignments.first
    assert_equal "Exam 1", precal_exam.name

    assert_equal 1, precal_exam.assignment_grades.count
    harry_precal_exam_grade = precal_exam.assignment_grades.first
    assert_equal harry, harry_precal_exam_grade.student
    assert_equal 95, harry_precal_exam_grade.returned_grade

    stam = user.courses.second
    assert_equal "456", stam.google_id
    assert_equal "STAM", stam.name
    assert_equal 1, stam.students.count
    assert_equal harry, stam.students.first

    DataSync::Helper.sync_data!(user, data_from_google)

    assert_equal 2, user.courses.count
    assert_equal 1, user.students.count
    assert_equal 1, Topic.count
    assert_equal 1, Assignment.count
    assert_equal 1, AssignmentGrade.count
    assert_equal 1, GradeCategory.count
  end
end
