class CreateAuditTrails < ActiveRecord::Migration[6.1]
  def change
    create_table :audit_trails do |t|
      t.string :resource_type
      t.string :action
      t.string :document_ids
      t.string :user
      t.timestamps
    end
  end
end
