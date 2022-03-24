# frozen_string_literal: true

class RolifyCreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table(:roles) do |t|
      t.string :name
      t.references :resource, polymorphic: true

      t.timestamps
    end

    create_table(:admins_roles, id: false) do |t|
      t.references :admin
      t.references :role
    end

    add_index(:roles, %i[name resource_type resource_id])
    add_index(:admins_roles, %i[admin_id role_id])
  end
end
