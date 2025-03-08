class GoogleService
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
              last_name: student_data.profile.name.last_name
            }
          end
        )
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