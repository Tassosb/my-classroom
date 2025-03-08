class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :data_syncs, dependent: :destroy
  has_many :courses, dependent: :destroy
  has_many :students, -> { distinct }, through: :courses

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.from_omni_auth(response)
    User.find_or_create_by(uuid: response[:uid]) do |u|
      u.email_address = response[:info][:email]

      u.password = SecureRandom.hex(15) # required by has_secure_password, but won't ever be used
    end
  end
end
