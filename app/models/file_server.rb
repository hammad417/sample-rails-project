# == Schema Information
#
# Table name: file_servers
#
#  id          :bigint           not null, primary key
#  filename    :string
#  identifier  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
#
# Indexes
#
#  index_file_servers_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
class FileServer < ApplicationRecord
  belongs_to :document

  def self.create_unique_record(document)
    fs = FileServer.new(document: document)
    fs.generate_unique_identifier
    fs.generate_unique_filename(document)
    fs.save ? fs : nil
  end

  def self.temp_storage_file_path(path)
    "#{MULAX_DOCUMENTS_FILE_SERVE_BASE_PATH}/#{path}"
  end

  def generate_unique_identifier
    return if self.identifier.present?
    loop do
      self.identifier = SecureRandom.send('choose', [*'0'..'9'], 20)
      break unless FileServer.exists?(identifier: identifier)
    end
  end

  def generate_unique_filename(document)
    filename_original = document.filename.split("_")
    filename_original.shift
    filename_original = filename_original.join("_")
    self.filename = "#{(DateTime.now).strftime('%Y%m%d%H%M%S%L')}#{SecureRandom.send('choose', [*'0'..'9'], 3)}_#{filename_original}"
  end
end
