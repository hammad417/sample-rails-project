class AddColumnsToAppAuthorization < ActiveRecord::Migration[6.1]
  def change
    add_column :app_authorizations, :client_id, :string
    add_column :app_authorizations, :refresh_token, :string
    rename_column :app_authorizations, :api_key, :access_token
  end
end
