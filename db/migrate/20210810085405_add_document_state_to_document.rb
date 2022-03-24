class AddDocumentStateToDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :archived, :boolean, default: false
  end
end
