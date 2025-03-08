class CreateDataSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :data_syncs do |t|
      t.timestamps
      t.datetime :started_at
      t.datetime :completed_at
      t.string :status, default: 'pending', null: false
    end
  end
end
