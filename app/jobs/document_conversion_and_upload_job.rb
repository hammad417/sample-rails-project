# frozen_string_literal: true
require 'rmagick'

class DocumentConversionAndUploadJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(document_id, document_file)
    document = Document.find_by(id: document_id)
    return unless document.present?

    if ['.jpeg', ".jpg", ".png", ".bmp", ".tif", ".tiff"].include?(File.extname(document_file))
      filename_without_extension = File.basename(document.filename, ".*")
      output_path = "#{MULAX_DOCUMENTS_FILE_SERVE_BASE_PATH}/#{(DateTime.now).strftime('%Y%m%d%H%M%S%L')}/#{filename_without_extension}.pdf"

      system "mkdir -p #{File.dirname(output_path)}"

      #convert image to pdf
      pdf = Magick::ImageList.new(document_file)
      pdf.write(output_path)
      new_filename = "#{File.basename(document.filename, ".*")}.pdf"
      new_file_path = "#{File.dirname(document.file_path)}/#{new_filename}"
      document.update(filename: new_filename, file_path: new_file_path)
    else
      output_path = document_file
    end
    FileUploadService.new(key: document.reload.file_path, file: output_path).upload

    if document.should_send_notification?
      PinpointNotificationService.new(document).call
      document.update(should_send_notification: false)
    end

    # Remove files after upload
    if File.exist?(document_file)
      FileUtils.remove_entry(document_file)
      FileUtils.remove_entry(File.dirname(document_file)) if File.dirname(document_file).starts_with?(MULAX_DOCUMENTS_FILE_SERVE_BASE_PATH)
    end
    if File.exist?(output_path)
      FileUtils.remove_entry(output_path)
      FileUtils.remove_entry(File.dirname(output_path)) if File.dirname(output_path).starts_with?(MULAX_DOCUMENTS_FILE_SERVE_BASE_PATH)
    end
  end
end
