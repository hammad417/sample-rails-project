class AddIsNotificationSentColumnToDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :should_send_notification, :boolean, default: false
  end
end
