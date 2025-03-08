class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.timestamps
      t.references :user, foreign_key: true, index: true, null: false
      t.string :name, null: false
      t.string :google_id, null: false
    end
  end
end
