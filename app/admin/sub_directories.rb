# frozen_string_literal: true

ActiveAdmin.register DocumentType do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name

  index do
    id_column
    column :name
    column :created_at
    column :updated_at
    actions
  end

end
