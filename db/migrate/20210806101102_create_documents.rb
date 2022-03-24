class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents do |t|
      t.string :filename, null: false
      t.string :file_path, null: false
      t.string :mode, null: false
      t.string :document_type, null: false
      t.string :classification, null: false
      t.text :description, null: true
      t.string :document_number, null: false
      t.string :issuer, null: false
      t.string :recipient, null: false
      t.string :recipient_id_type, null: false
      t.datetime :issue_date, null: false
      t.datetime :effective_date, null: true
      t.datetime :expiration_date, null: true
      t.string :reference_type, null: true
      t.string :reference_number, null: true
      t.string :other_reference_type, null: true
      t.string :other_reference_number, null: true
      t.text :issuer_signature_1, null: true
      t.string :issuer_sign_name_1, null: true
      t.datetime :issuer_sign_datetime_1, null: true
      t.text :issuer_signature_2, null: true
      t.string :issuer_sign_name_2, null: true
      t.datetime :issuer_sign_datetime_2, null: true
      t.text :recipient_signature_1, null: true
      t.string :recipient_sign_name_1, null: true
      t.datetime :recipient_sign_datetime_1, null: true
      t.text :recipient_signature_2, null: true
      t.string :recipient_sign_name_2, null: true
      t.datetime :recipient_sign_datetime_2, null: true

      t.text :witness_signature, null: true
      t.string :witness_sign_name, null: true
      t.datetime :witness_sign_datetime, null: true

      t.timestamps
    end
  end
end
