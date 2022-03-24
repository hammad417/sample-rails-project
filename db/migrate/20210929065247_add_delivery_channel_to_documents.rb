class AddDeliveryChannelToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :identifier, :string
    add_column :documents, :prefix, :string
    add_column :documents, :identifier_key, :string
    add_column :documents, :delivery_channel, :string
  end
end
