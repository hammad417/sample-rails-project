class CreateArchiveDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :archive_documents do |t|
      t.string :filename
      t.string :file_path
      t.references :document, null: false, foreign_key: true

      t.timestamps
    end
  end
end
