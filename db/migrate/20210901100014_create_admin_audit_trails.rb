class CreateAdminAuditTrails < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_audit_trails do |t|
      t.string :email
      t.boolean :super_admin
      t.string :roles_titles
      t.datetime :login_time
      t.datetime :logout_time
      t.references :admin
      t.timestamps
    end
  end
end
