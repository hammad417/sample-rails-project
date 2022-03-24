# == Schema Information
#
# Table name: documents
#
#  id                             :bigint           not null, primary key
#  archived                       :boolean          default(FALSE)
#  classification                 :string           not null
#  delivery_channel               :string
#  description                    :text
#  document_number                :string           not null
#  document_type                  :string           not null
#  effective_date                 :datetime
#  expiration_date                :datetime
#  file_path                      :string
#  filename                       :string
#  identifier                     :string
#  identifier_key                 :string
#  is_temp                        :boolean          default(FALSE)
#  issue_date                     :datetime         not null
#  issuer                         :string           not null
#  issuer_sign_datetime_1         :datetime
#  issuer_sign_datetime_2         :datetime
#  issuer_sign_name_1             :string
#  issuer_sign_name_2             :string
#  issuer_signature_1             :text
#  issuer_signature_1_filename    :string
#  issuer_signature_2             :text
#  issuer_signature_2_filename    :string
#  mode                           :string           not null
#  other_reference_number         :string
#  other_reference_type           :string
#  prefix                         :string
#  recipient                      :string           not null
#  recipient_id_type              :string           not null
#  recipient_sign_datetime_1      :datetime
#  recipient_sign_datetime_2      :datetime
#  recipient_sign_name_1          :string
#  recipient_sign_name_2          :string
#  recipient_signature_1          :text
#  recipient_signature_1_filename :string
#  recipient_signature_2          :text
#  recipient_signature_2_filename :string
#  reference_number               :string
#  reference_type                 :string
#  sender                         :string
#  should_send_notification       :boolean          default(FALSE)
#  witness_sign_datetime          :datetime
#  witness_sign_name              :string
#  witness_signature              :text
#  witness_signature_filename     :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
class DocumentSerializer
  include JSONAPI::Serializer
  attributes :mode, :document_type, :classification, :document_number, :filename, :issuer, :recipient,
             :recipient_id_type, :issue_date, :effective_date, :expiration_date, :description, :reference_type,
             :reference_number, :other_reference_type, :other_reference_number, :issuer_signature_1,
             :issuer_signature_1_filename, :issuer_sign_name_1, :issuer_sign_datetime_1,
             :issuer_signature_2, :issuer_signature_2_filename, :issuer_sign_name_2,
             :issuer_sign_datetime_2, :recipient_signature_1, :recipient_signature_1_filename, :recipient_sign_name_1,
             :recipient_signature_2, :recipient_signature_2_filename, :recipient_sign_datetime_1, :recipient_sign_name_2,
             :recipient_sign_datetime_2, :witness_signature, :witness_signature_filename, :witness_sign_name,
             :witness_sign_datetime, :created_at, :updated_at
end
