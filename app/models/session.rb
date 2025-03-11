class Session < ApplicationRecord
  serialize :omni_auth, coder: JSON
  encrypts :omni_auth

  belongs_to :user
end
