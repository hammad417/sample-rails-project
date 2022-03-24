# frozen_string_literal: true

class FileUploadService
  attr_reader :key, :file

  def initialize(key:, file:)
    @key = key
    @file = file
  end

  def upload
    FileUtils.mkdir_p File.dirname(key)
    FileUtils.cp(file, key)
  rescue StandardError => e
    Rails.logger.log 'Error Uploading file to Drive'
    Rails.logger.log e.message
  end
end

