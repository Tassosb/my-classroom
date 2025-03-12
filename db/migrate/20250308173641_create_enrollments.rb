class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.timestamps
      t.references :student, foreign_key: true, index: true, null: false
      t.references :course, foreign_key: true, index: true, null: false
    end
    add_index :enrollments, [ :student_id, :course_id ], unique: true
  end
end
