# frozen_string_literal: true

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
require 'base64'
class Document < ApplicationRecord
  include Filterable

  DOCUMENT_MODES = %w[draft final].freeze
  DOCUMENT_CLASSIFICATION = %w[private public internal confidential restricted].freeze
  RECIPIENT_ID_TYPE = %w[id uid uuid uname name phone email].freeze
  DOCUMENT_FILE_VALID_FORMATS = ["pdf", 'jpeg', "jpg", "png", "bmp", "tif", "tiff", "xls", "xlsx"]
  DOCUMENT_MAX_CHARACTERS_FOR_SIGNATURE_TEXT = 500

  scope :filter_by_mode, ->(mode) { where(mode: mode) }
  scope :filter_by_document_type, ->(doc_type) { where(document_type: doc_type) }
  scope :filter_by_classification, ->(c) { where(classification: c) }
  scope :filter_by_filename, ->(f) { where('filename ILIKE ?', "%#{f}%") }
  scope :filter_by_file_path, ->(f) { where('file_path ILIKE ?', "%#{f}%") }
  scope :filter_by_document_number, ->(d) { where('document_number ILIKE ?', "%#{d}%") }
  scope :filter_by_reference_number, ->(i) { where(reference_number: i) }
  scope :filter_by_reference_type, ->(i) { where(reference_type: i) }
  scope :filter_by_other_reference_number, ->(i) { where(other_reference_number: i) }
  scope :filter_by_other_reference_type, ->(i) { where(other_reference_type: i) }
  scope :filter_by_recipient, ->(i) { where(recipient: i) }
  scope :filter_by_issuer, ->(i) { where(issuer: i) }
  scope :filter_by_issue_date_from, ->(date) { where('issue_date >= ?', "#{date}") }
  scope :filter_by_issue_date_to, ->(date) { where('issue_date <= ?', "#{date}") }

  scope :temp_documents, -> { where(is_temp: true, archived: false) }
  scope :active, -> { where(is_temp: false, archived: false) }
  scope :delivery_channel_email, -> { where(delivery_channel: 'email') }

  # only trace filename and filepath because its only we are interested in
  has_paper_trail on: [:update]


  attr_accessor :issuer_signature_1_base64, :issuer_signature_2_base64, :recipient_signature_1_base64, :recipient_signature_2_base64
  attr_accessor :upload_document_file, :issuer_signature_1_file, :issuer_signature_2_file, :recipient_signature_1_file, :recipient_signature_2_file, :witness_signature_file
  attr_accessor :skip_document_file_validations
  attr_writer :witness_signature_base64

  before_save :assign_document_type
  before_validation :downcase_fields

  def witness_signature_base64
    self.witness_signature
  end

  has_many :archive_documents

  validates :mode, :document_type, :classification, :document_number, :issuer, :issue_date,
            :recipient, :recipient_id_type, presence: true
  validates :filename, :file_path, presence: {unless: :skip_document_file_validations}

  validates_inclusion_of :mode, in: DOCUMENT_MODES
  validates_inclusion_of :classification, in: DOCUMENT_CLASSIFICATION
  validates_inclusion_of :recipient_id_type, in: RECIPIENT_ID_TYPE

  validates_datetime :issue_date, invalid_datetime_message: "should be a valid date and not null"
  validates_datetime :expiration_date, :expiration_date, :issuer_sign_datetime_1, :issuer_sign_datetime_2,
                     :recipient_sign_datetime_1, :recipient_sign_datetime_2, :witness_sign_datetime, allow_blank: true, invalid_datetime_message: "is not a valid date"

  validate :check_file_extension, unless: :skip_document_file_validations

  validate :check_files_sizes

  def self.filter_document_type_eq(value)
    if value == "OTHER"
      where.not(document_type: DocumentType.pluck(:name))
    else
      where(document_type: value)
    end
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i(filter_document_type_eq)
  end

  def self.temp_storage_path_for_sftp(sender, identifier)
    "#{MULAX_DOCUMENTS_SFTP_BASE_PATH}/#{sender}/#{identifier}"
  end

  def self.create_audit_trail(action:, user:, document_ids: nil)
    AuditTrail.create(resource_type: "Document", action: action, user: user, document_ids: document_ids)
  end

  def downloadable?
    self.filename.present? && self.file_path.present?
  end

  def active?
    self.archived? == false && self.is_temp? == false
  end

  def assign_signature_attributes(params)
    %i[issuer_signature_1 issuer_signature_2 recipient_signature_1 recipient_signature_2
       witness_signature].each do |sign|
      next if params[sign].blank? && params["#{sign}_base64".to_sym].blank?

      if params[sign].present?
        next if is_file_size_greater_than_allowed?(file: params[sign], sign: sign)
        self[sign] = encode_file_to_base64_string(params[sign].tempfile)
        self["#{sign}_filename"] = params[sign].original_filename
      else
        base64_string = params["#{sign}_base64".to_sym]
        set_signature_attribute_from_base64_string(base64_string: base64_string, attribute: sign)
      end
    end
  end

  def assign_signature_attributes_for_api(params)
    %i[issuer_signature_1 issuer_signature_2 recipient_signature_1 recipient_signature_2
       witness_signature].each do |sign|
      next if params[sign].blank?
      if params[sign].is_a?(String)
        set_signature_attribute_from_base64_string(base64_string: params[sign], attribute: sign)
      else
        next if is_file_size_greater_than_allowed?(file: params[sign], sign: sign)
        self[sign] = encode_file_to_base64_string(params[sign].tempfile)
        self["#{sign}_filename"] = params[sign].original_filename
      end
    end
  end

  def assign_attributes_from_document_object_in_api(doc)
    self.document_number = doc[:document_number] if doc[:document_number].present?
    self.recipient = doc[:recipient] if doc[:recipient].present?
    self.recipient_id_type = doc[:recipient_id_type] if doc[:recipient_id_type].present?
    self.reference_number = doc[:reference_number] if doc[:reference_number].present?
  end

  def assign_file_attributes(file)
    return unless file.present?
    return if is_file_size_greater_than_allowed?(file: file, sign: :upload_document)
    # convert image to pdf format
    if ['.jpeg', ".jpg", ".png", ".bmp", ".tif",".tiff"].include?(File.extname(file.original_filename))
      require 'rmagick'
      filename_without_extension = File.basename(file.original_filename, ".*")
      output_path = "#{File.dirname(file.tempfile.path)}/#{filename_without_extension}.pdf"

      #convert image to pdf
      pdf = Magick::ImageList.new(file.tempfile.path)
      pdf.write(output_path)

      #Change reference for uploaded file to this new pdf file
      file.original_filename = File.basename(output_path)
      temp_file = Tempfile.new([filename_without_extension, ".pdf"], File.dirname(file.tempfile.path))
      open(output_path) { |f| temp_file.write(f.read) }
      file.tempfile = temp_file
    end
    assign_filename_and_path(file)

  end

  def assign_file_attributes_for_api(file)
    return unless file.present?
    return if is_file_size_greater_than_allowed?(file: file, sign: :upload_document)
    assign_filename_and_path(file)
  end

  def assign_file_attributes_for_sftp(sender, identifier)
    return unless identifier.present? && sender.present?
    identifier_with_extension_for_dir_search = File.extname(identifier).present? ? identifier : "#{identifier}.*"
    return unless Dir[Document.temp_storage_path_for_sftp(sender, identifier_with_extension_for_dir_search)].any?
    identifier = Dir[Document.temp_storage_path_for_sftp(sender, identifier_with_extension_for_dir_search)].first
    file = File.read(identifier)
    return if is_file_size_greater_than_allowed?(file: file, sign: :upload_document)
    assign_filename_and_path_sftp(identifier)
  end

  def assign_filename_and_path_sftp(identifier)
    return unless identifier.present?
    generate_unique_filename(identifier)
  end

  def draft?
    mode == 'draft'
  end

  def final?
    mode == 'final'
  end

  def archived!
    update!(archived: true)
  end

  def generate_archive_document
    doc_history = self.paper_trail.previous_version
    self.archive_documents.create(filename: doc_history.filename, file_path: doc_history.file_path) if (doc_history.present? && doc_history.filename.present?)
  end

  def assign_document_type
    if self.document_type.present? && self.document_type_white_listed.present?
      self.document_type = self.document_type_white_listed.name
    end
  end

  def document_type_white_listed
    DocumentType.where('lower(name) = ?', self.document_type.downcase).first
  end

  private

  def downcase_fields
    self.mode = self.mode.downcase if self.mode.present?
    self.classification = self.classification.downcase if self.classification.present?
    self.recipient_id_type = self.recipient_id_type.downcase if self.recipient_id_type.present?
  end

  def set_signature_attribute_from_base64_string(base64_string:, attribute:)
    unless base64_string.size <= DOCUMENT_MAX_CHARACTERS_FOR_SIGNATURE_TEXT
      file_type = ParseBase64String.new(base64_string: base64_string).detect_file_type
      if file_type.present?
        self["#{attribute}_filename"] = "#{attribute}.#{file_type}"
      end
    end
    self[attribute] = base64_string
  end

  def encode_file_to_base64_string(file)
    data = File.open(file).read
    Base64.strict_encode64(data)
  end

  def is_file_size_greater_than_allowed?(file:, sign:)
    if file.size / ONE_MEGABYTE_IN_BYTES > MAX_FILE_SIZE_IN_MB
      self.send("#{sign}_file=", file)
      return true
    end
    false
  end

  def generate_unique_filename(original_file_name)
    today_date = (DateTime.now).strftime('%Y%m%d')
    today_date_with_time = (DateTime.now).strftime('%Y%m%d%H%M%S')
    file_name = "#{today_date_with_time}_#{original_file_name}"
    self.filename = file_name
    if self.document_type_white_listed.present?
      self.file_path = "#{MULAX_DOCUMENTS_BASE_PATH}/docs/#{today_date}/#{self.document_type}/#{file_name}"
    else
      self.file_path = "#{MULAX_DOCUMENTS_BASE_PATH}/docs/#{today_date}/OTHER/#{file_name}"
    end

  end

  def assign_filename_and_path(file)
    return unless file.present?
    generate_unique_filename(file.original_filename)
  end

  def check_file_extension
    return if filename.present? && DOCUMENT_FILE_VALID_FORMATS.include?(filename.split('.').last)
    errors.add(:base, 'Please select document file in valid format')
  end

  def check_files_sizes
    %i[upload_document_file issuer_signature_1_file issuer_signature_2_file recipient_signature_1_file recipient_signature_2_file witness_signature_file].each do |sign|
      if self.send(sign).present? && self.send(sign).size / ONE_MEGABYTE_IN_BYTES > MAX_FILE_SIZE_IN_MB
        self.errors.add(:base, "File size for #{sign} greater than #{MAX_FILE_SIZE_IN_MB} MB. Please select a one with less size")
      end
    end
  end
end
