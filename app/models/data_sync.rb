class DataSync < ApplicationRecord
  belongs_to :user

  def run!
    # TODO: Persist the google token on data_syncs instead of grabbing the last user session
    # What if the user starts a data sync then logs out before it finishes?
    user_session = user.sessions.order(:created_at).last
    raise "No current session" if user_session.nil?

    update!(started_at: Time.zone.now)
    api = GoogleAPI.from_omni_auth(user_session.omni_auth.symbolize_keys!)
    Helper.sync_data!(user, api.classroom_data)
    update!(completed_at: Time.zone.now)
  end

  def duration
    completed_at - started_at if completed_at && started_at
  end

  module Helper
    def self.sync_data!(user, data)
      ApplicationRecord.transaction do
        user.courses.destroy_all

        student_cache = {}

        data[:courses_attrs].each do |course_attrs|
          students = course_attrs[:students_attrs].map do |student_attrs|
            student_cache[student_attrs[:google_id]] ||
              Student.new(student_attrs.slice(:google_id, :first_name, :last_name))
          end

          course = user.courses.create!(course_attrs.slice(:google_id, :name))

          course.students = students

          course.students.each do |student|
            student_cache[student.google_id] = student
          end

          topics = course_attrs[:topics_attrs].map do |topic_attrs|
            Topic.new(topic_attrs.slice(:google_id, :name))
          end
          course.topics = topics
          topics_cache = topics.index_by(&:google_id)

          grade_categories = course_attrs[:grade_categories_attrs].map do |grade_category_attrs|
            GradeCategory.new(grade_category_attrs.slice(:google_id, :name, :weight))
          end
          course.grade_categories = grade_categories
          grade_categories_cache = grade_categories.index_by(&:google_id)

          assignments = course_attrs[:assignments_attrs].map do |assignment_attrs|
            topic = topics_cache[assignment_attrs[:topic_google_id]]
            grade_category = grade_categories_cache[assignment_attrs[:grade_category_google_id]]

            assignment = course.assignments.create!(
              topic: topic,
              grade_category: grade_category,
              **assignment_attrs.slice(:google_id, :name, :max_points, :due_on)
            )

            assignment_grades = assignment_attrs[:assignment_grades_attrs].map do |assignment_grade_attrs|
              student = student_cache[assignment_grade_attrs[:student_google_id]]
              student.assignment_grades.build(assignment_grade_attrs.slice(:google_id, :draft_grade, :returned_grade))
            end

            assignment.assignment_grades = assignment_grades
          end
        end
      end
    end
  end
end
