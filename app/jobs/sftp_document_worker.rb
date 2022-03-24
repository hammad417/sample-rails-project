# frozen_string_literal: true

require 'sidekiq-scheduler'

class SftpDocumentWorker
  include Sidekiq::Worker

  def perform(*_args)
    Document.temp_documents.order(id: :asc).find_each do |document|
      next if document.reload.archived? # If document marked as archived during this process do not process it
      filename = document.filename
      sender = document.sender
      #if extension included in file, then use it otherwise add asterisk as extension
      identifier_with_extension_for_dir_search = File.extname(filename).present? ? filename : "#{filename}.*"
      next unless Dir[Document.temp_storage_path_for_sftp(sender, identifier_with_extension_for_dir_search)].any?

      identifier = Dir[Document.temp_storage_path_for_sftp(sender, identifier_with_extension_for_dir_search)].first
      document.assign_filename_and_path_sftp(File.basename(identifier))
      document.is_temp = false
      document.save
      Document.temp_documents.where(filename: filename,sender: sender).where.not(id:document.id).update_all( archived: true)
      DocumentConversionAndUploadJob.perform_async(document.id, identifier)
    end
  end
end
