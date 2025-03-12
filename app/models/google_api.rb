require "google/api_client/client_secrets"

class GoogleAPI
  attr_reader :tokens

  def self.session_authorized?(session)
    api = self.from_omni_auth(session.omni_auth)
    api.authorized?
  end

  def self.from_omni_auth(omni_auth)
    self.new(
      access_token: omni_auth[:token],
      refresh_token: omni_auth[:refresh_token],
      expires_at: omni_auth[:expires_at]
    )
  end

  def initialize(**tokens)
    @tokens = tokens
  end

  def authorized?
    classroom_service.list_courses(page_size: 0)
    true
  rescue Google::Apis::AuthorizationError, Signet::AuthorizationError
    false
  end

  def classroom_data
    {
      courses_attrs: classroom_service.list_courses(teacher_id: "me").courses.map do |course_data|
        grade_categories_data = course_data.gradebook_settings.grade_categories || []
        students_data = classroom_service.list_course_students(course_data.id, fields: "students/profile").students

        topics_data = classroom_service.list_course_topics(course_data.id).topic || []

        assignment_fields = %w[
          course_work/id
          course_work/title
          course_work/topic_id
          course_work/max_points
          course_work/due_date
          course_work/work_type
          course_work/state
          course_work/grade_category/id
        ].join(",")
        assignments_data = classroom_service.list_course_works(course_data.id, fields: assignment_fields).course_work || []

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
            ].join(",")
            assignment_grades_data = classroom_service.list_student_submissions(
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

  private

  def classroom_service
    Google::Apis::ClassroomV1::ClassroomService.new.tap do |service|
      service.authorization = Google::APIClient::ClientSecrets.new(web: tokens).to_authorization
    end
  end

  def stringify_date(google_date)
    return "" if google_date.nil?
    [ google_date.year, google_date.month, google_date.day ].join("-")
  end
end
