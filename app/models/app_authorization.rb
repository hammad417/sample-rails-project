# == Schema Information
#
# Table name: app_authorizations
#
#  id            :bigint           not null, primary key
#  access_token  :string           not null
#  refresh_token :string
#  secret        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string
#
class AppAuthorization < ApplicationRecord
  SECRET_HEX_LENGTH = 8
  ACCESS_TOKEN_HEX_LENGTH = 64

  validates_presence_of :client_id, :secret, :access_token, :refresh_token
  validates_uniqueness_of :client_id

  def generate_secret_and_tokens
    self.secret = SecureRandom.hex(AppAuthorization::SECRET_HEX_LENGTH)
    self.access_token = SecureRandom.hex(AppAuthorization::ACCESS_TOKEN_HEX_LENGTH)
    self.refresh_token = SecureRandom.hex(AppAuthorization::ACCESS_TOKEN_HEX_LENGTH)
  end

  def update_access_token
    self.update(access_token: SecureRandom.hex(AppAuthorization::ACCESS_TOKEN_HEX_LENGTH))
  end
end
