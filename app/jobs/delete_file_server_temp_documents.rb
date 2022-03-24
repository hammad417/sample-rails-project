# frozen_string_literal: true

require 'sidekiq-scheduler'

class DeleteFileServerTempDocuments
  include Sidekiq::Worker

  def perform(*_args)
    delete_ids = []
    FileServer.find_each do |file_server|
      if (Time.now - file_server.created_at) > LINK_EXPIRE_TIME_FOR_FILE_SERVER_IN_SECONDS
        filename = file_server.filename
        file_path = FileServer.temp_storage_file_path(filename)
        FileUtils.remove_entry(file_path) if File.exist?(file_path)
        delete_ids << file_server.id
      end
    end
    FileServer.where(id: delete_ids).delete_all if delete_ids.present?
  end
end