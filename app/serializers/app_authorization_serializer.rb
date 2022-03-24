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
class AppAuthorizationSerializer
  include JSONAPI::Serializer
  attributes :client_id, :secret, :access_token, :refresh_token
end
