class AddUserIdToDataSyncs < ActiveRecord::Migration[8.0]
  def change
    add_reference :data_syncs, :user, index: true, foreign_key: true, null: false
  end
end
