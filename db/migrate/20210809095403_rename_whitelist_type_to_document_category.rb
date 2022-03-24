class RenameWhitelistTypeToDocumentCategory < ActiveRecord::Migration[6.1]
  def change
    rename_table :whitelist_types, :sub_directories
  end
end
