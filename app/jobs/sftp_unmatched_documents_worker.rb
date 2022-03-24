# frozen_string_literal: true

require 'sidekiq-scheduler'
require 'fileutils'

class SftpUnmatchedDocumentsWorker
  include Sidekiq::Worker

  def perform(*_args)
    ten_minutes_in_seconds = 600
    Dir.glob("#{MULAX_DOCUMENTS_SFTP_BASE_PATH}/*").each do |directory_path|
      if File.directory?(directory_path)
        Dir["#{directory_path}/*"].each do |file_path|
          if (Time.now.utc - File.stat(file_path).atime.utc).to_i >= ten_minutes_in_seconds
            FileUtils.mv(file_path, MULAX_DOCUMENTS_TRASH_PATH)
          end
        end
      end
    end
  end
end
