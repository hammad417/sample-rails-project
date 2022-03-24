class AddObjectChangeColumnToPaperTrail < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :object_changes, :json
  end
end
