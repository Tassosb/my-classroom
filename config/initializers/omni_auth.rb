Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 
           Rails.application.credentials.google.client_id, 
           Rails.application.credentials.google.client_secret,
           scope: %w[
             email
             classroom.coursework.students
             classroom.courses
             classroom.rosters.readonly
             classroom.student-submissions.students.readonly
           ],
           prompt: 'consent'
end
# Sage (STAM): 110499431832195285133
# Sage (Precal): 110499431832195285133