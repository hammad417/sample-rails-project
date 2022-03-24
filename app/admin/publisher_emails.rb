# frozen_string_literal: true

ActiveAdmin.register PublisherEmail do

  permit_params :email

  index do
    id_column
    column :email
    actions
  end
end
