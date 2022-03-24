# frozen_string_literal: true

class CopyFileToTempFileServerJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(original_file_path, new_file_name)
    return unless original_file_path.present?
    new_file_path = FileServer.temp_storage_file_path(new_file_name)
    FileUtils.mkdir_p File.dirname(new_file_path)
    FileUtils.cp(original_file_path, new_file_path)
  rescue StandardError => e
    Rails.logger.log 'Error copying file to temp Drive'
    Rails.logger.log e.message
  end
end
