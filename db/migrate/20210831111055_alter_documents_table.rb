class AlterDocumentsTable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :documents, :filename, true
    change_column_null :documents, :file_path, true
    add_column :documents, :is_temp, :boolean, default: false
    add_column :documents, :sender, :string
  end
end
