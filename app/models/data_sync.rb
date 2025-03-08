class DataSync < ApplicationRecord
  def run!
    service = Google::Apis::ClassroomV1::ClassroomService.new
    service.authorization = Current.session.google_token

    transaction do
      # user.courses.delete_all!

      service.list_courses.courses.each do |course|
        # list course students
        # list course works
          # list student submissions
      end
    end
  end
end
