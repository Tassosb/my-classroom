class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.timestamps
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :google_id, null: false
    end
  end
end
