class RenameWhitelistEmailTable < ActiveRecord::Migration[6.1]
  def change
    rename_table :whitelist_emails, :publisher_emails
  end
end
