class RenameSubdirectoryTable < ActiveRecord::Migration[6.1]
  def change
    rename_table :sub_directories, :document_types
  end
end
