class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.timestamps
      t.string :google_id
      t.string :name
      t.references :course, foreign_key: true, index: true, null: false
    end
  end
end
