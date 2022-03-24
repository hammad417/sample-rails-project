class CreateFileServers < ActiveRecord::Migration[6.1]
  def change
    create_table :file_servers do |t|
      t.references :document, null: false, foreign_key: true
      t.string :filename
      t.string :identifier

      t.timestamps
    end
  end
end
