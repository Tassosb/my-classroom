class DataSync < ApplicationRecord
  belongs_to :user

  def run!
    # TODO: Persist the google token on data_syncs instead of grabbing the last user session
    # What if the user starts a data sync then logs out before it finishes?
    user_session = user.sessions.order(:created_at).last
    raise 'No current session' if user_session.nil?

    request = GoogleClassroomRequest.new(token: user_session.google_token)

    Helper.sync_data!(user, request.data)
  end

  module Helper
    def self.sync_data!(user, data)
      ApplicationRecord.transaction do
        user.courses.destroy_all
  
        student_cache = {}
  
        data[:courses_attrs].each do |course_attrs|
          students = course_attrs[:students_attrs].map do |student_attrs|
            student_cache[student_attrs[:google_id]] || Student.new(student_attrs.slice(:google_id, :first_name, :last_name))
          end
  
          course = user.courses.create!(course_attrs.slice(:google_id, :name))
  
          course.students = students
  
          course.students.each do |student|
            student_cache[student.google_id] = student
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
      {
        courses_attrs: api_service.list_courses.courses.map do |course_data|
          students_data = service.list_course_students(course_data.id).students
          
          {
            name: course_data.name,
            google_id: course_data.id,
            students_attrs: students_data.map do |student_data|
              {
                google_id: student_data.profile.id,
                first_name: student_data.profile.name.given_name,
                last_name: student_data.profile.name.last_name,
                assignment_grades_attrs: []
              }
            end,
            assignments_attrs: []
          }
        end
      }
    end
  
    private
  
    def api_service
      service = Google::Apis::ClassroomV1::ClassroomService.new
      service.authorization = user_session.google_token
      service
    end
  end
end
