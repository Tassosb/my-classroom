unless Rails.env.test?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
            Rails.application.credentials.google.client_id,
            Rails.application.credentials.google.client_secret,
            scope: %w[
              email
              classroom.coursework.students.readonly
              classroom.courses.readonly
              classroom.rosters.readonly
              classroom.student-submissions.students.readonly
              classroom.topics.readonly
            ],
            prompt: "consent"
  end
end