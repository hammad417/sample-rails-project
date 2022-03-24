# frozen_string_literal: true

class AddSuperAdminFieldToAdmin < ActiveRecord::Migration[6.1]
  def change
    add_column :admins, :super_admin, :boolean, default: false
  end
end
