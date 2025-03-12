class CreateAssignmentGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :assignment_grades do |t|
      t.timestamps
      t.string :google_id, null: false
      t.integer :draft_grade
      t.integer :returned_grade
      t.references :assignment, foreign_key: true, index: true, null: false
      t.references :student, foreign_key: true, index: true, null: false
    end
    add_index :assignment_grades, [ :student_id, :assignment_id ], unique: true
  end
end
