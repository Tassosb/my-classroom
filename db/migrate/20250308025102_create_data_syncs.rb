class CreateDataSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :data_syncs do |t|
      t.timestamps
    end
  end
end
