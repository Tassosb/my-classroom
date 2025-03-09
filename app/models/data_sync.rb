class DataSync < ApplicationRecord
  belongs_to :user

  def run!
    # TODO: Persist the google token on data_syncs instead of grabbing the last user session
    # What if the user starts a data sync then logs out before it finishes?
    user_session = user.sessions.order(:created_at).last
    raise 'No current session' if user_session.nil?

    request = GoogleClassroomRequest.new(token: user_session.google_token)

    update!(started_at: Time.zone.now)
    Helper.sync_data!(user, request.data)
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

  class GoogleClassroomRequest
    attr_reader :token
  
    def initialize(token:)
      @token = token
    end
  
    def data
      service = Google::Apis::ClassroomV1::ClassroomService.new
      service.authorization = token
      {
        courses_attrs: service.list_courses(teacher_id: 'me').courses.map do |course_data|
          grade_categories_data = course_data.gradebook_settings.grade_categories || []
          students_data = service.list_course_students(course_data.id, fields: 'students/profile').students

          topics_data = service.list_course_topics(course_data.id).topic || []

          assignment_fields = %w[
            course_work/id
            course_work/title
            course_work/topic_id
            course_work/max_points
            course_work/due_date
            course_work/work_type
            course_work/state
            course_work/grade_category/id
          ].join(',')
          assignments_data = service.list_course_works(course_data.id, fields: assignment_fields).course_work || []

          {
            name: course_data.name,
            google_id: course_data.id,
            section: course_data.section,
            grade_categories_attrs: grade_categories_data.map do |grade_category_data|
              {
                google_id: grade_category_data.id,
                name: grade_category_data.name,
                weight: grade_category_data.weight
              }
            end,
            students_attrs: students_data.map do |student_data|
              {
                google_id: student_data.profile.id,
                first_name: student_data.profile.name.given_name,
                last_name: student_data.profile.name.family_name
              }
            end,
            topics_attrs: topics_data.map do |topic_data| 
              { google_id: topic_data.topic_id, name: topic_data.name }
            end,
            assignments_attrs: assignments_data.map do |assignment_data|
              assignment_grade_fields = %w[
                student_submissions/id
                student_submissions/draft_grade
                student_submissions/assigned_grade
                student_submissions/user_id
                student_submissions/course_work_type
              ].join(',')
              assignment_grades_data = service.list_student_submissions(
                                                course_data.id, 
                                                assignment_data.id, 
                                                fields: assignment_grade_fields
                                              )
                                              .student_submissions || []
              {
                google_id: assignment_data.id,
                name: assignment_data.title,
                topic_google_id: assignment_data.topic_id,
                max_points: assignment_data.max_points || 0,
                due_on: stringify_date(assignment_data.due_date),
                type: assignment_data.work_type,
                grade_category_google_id: assignment_data.grade_category&.id,
                assignment_grades_attrs: assignment_grades_data.map do |assignment_grade_data|
                  {
                    google_id: assignment_grade_data.id,
                    draft_grade: assignment_grade_data.draft_grade,
                    returned_grade: assignment_grade_data.assigned_grade,
                    student_google_id: assignment_grade_data.user_id,
                    assignment_type: assignment_grade_data.course_work_type
                  }
                end
              }
            end
          }
        end
      }
    end

    def stringify_date(google_date)
      return '' if google_date.nil?
      [google_date.year, google_date.month, google_date.day].join('-')
    end
  end
end
