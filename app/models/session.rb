class Session < ApplicationRecord
  encrypts :google_token

  belongs_to :user
end
