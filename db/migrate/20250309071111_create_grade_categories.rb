class CreateGradeCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :grade_categories do |t|
      t.timestamps
      t.string :google_id, null: false
      t.string :name, null: false
      t.integer :weight, null: false
      t.references :course, foreign_key: true, index: true, null: false
    end

    add_reference :assignments, :grade_category, index: true, foreign_key: true, null: true
  end
end
