class CreateAppAuthorizations < ActiveRecord::Migration[6.1]
  def change
    create_table :app_authorizations do |t|
      t.string :api_key, null: false
      t.string :secret, null: false

      t.timestamps
    end
  end
end
