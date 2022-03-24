class AddFilenameColumnsForSignaturesFieldInDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :issuer_signature_1_filename, :string
    add_column :documents, :issuer_signature_2_filename, :string
    add_column :documents, :recipient_signature_1_filename, :string
    add_column :documents, :recipient_signature_2_filename, :string
    add_column :documents, :witness_signature_filename, :string
  end
end
