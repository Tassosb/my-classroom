# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_09_090752) do
  create_table "assignment_grades", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id", null: false
    t.integer "draft_grade"
    t.integer "returned_grade"
    t.integer "assignment_id", null: false
    t.integer "student_id", null: false
    t.index ["assignment_id"], name: "index_assignment_grades_on_assignment_id"
    t.index ["student_id", "assignment_id"], name: "index_assignment_grades_on_student_id_and_assignment_id", unique: true
    t.index ["student_id"], name: "index_assignment_grades_on_student_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id", null: false
    t.string "name", null: false
    t.date "due_on"
    t.integer "max_points", default: 0, null: false
    t.integer "course_id", null: false
    t.integer "topic_id"
    t.integer "grade_category_id"
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["grade_category_id"], name: "index_assignments_on_grade_category_id"
    t.index ["topic_id"], name: "index_assignments_on_topic_id"
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "google_id", null: false
    t.index ["user_id"], name: "index_courses_on_user_id"
  end

  create_table "data_syncs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "status", default: "pending", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_data_syncs_on_user_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "student_id", null: false
    t.integer "course_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["student_id", "course_id"], name: "index_enrollments_on_student_id_and_course_id", unique: true
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "grade_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id", null: false
    t.string "name", null: false
    t.integer "weight", null: false
    t.integer "course_id", null: false
    t.index ["course_id"], name: "index_grade_categories_on_course_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.text "omni_auth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "google_id", null: false
  end

  create_table "topics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id"
    t.string "name"
    t.integer "course_id", null: false
    t.index ["course_id"], name: "index_topics_on_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "assignment_grades", "assignments"
  add_foreign_key "assignment_grades", "students"
  add_foreign_key "assignments", "courses"
  add_foreign_key "assignments", "grade_categories"
  add_foreign_key "assignments", "topics"
  add_foreign_key "courses", "users"
  add_foreign_key "data_syncs", "users"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "students"
  add_foreign_key "grade_categories", "courses"
  add_foreign_key "sessions", "users"
  add_foreign_key "topics", "courses"
end
