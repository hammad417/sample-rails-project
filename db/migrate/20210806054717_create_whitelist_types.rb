class CreateWhitelistTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :whitelist_types do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
