class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.timestamps
      t.string :google_id, null: false
      t.string :name, null: false
      t.date :due_on
      t.integer :max_points, null: false, default: 0
      t.references :course, foreign_key: true, index: true, null: false
      t.references :topic, foreign_key: true, index: true, null: true
    end
  end
end
