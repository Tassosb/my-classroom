class AddOmniAuthToSessions < ActiveRecord::Migration[8.0]
  def change
    rename_column :sessions, :google_token, :omni_auth

    reversible do |m|
      m.up { change_column :sessions, :omni_auth, :text }
      m.down { change_column :sessions, :omni_auth, :string }
    end
  end
end
