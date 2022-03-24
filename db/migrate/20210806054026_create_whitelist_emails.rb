class CreateWhitelistEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :whitelist_emails do |t|
      t.string :email, null: false

      t.timestamps
    end
  end
end
