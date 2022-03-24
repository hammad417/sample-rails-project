class FileServersController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def serve_file
    identifier = params[:identifier]
    if identifier.present?
      file_server = FileServer.find_by(identifier: identifier)
      if file_server.present?
        if (Time.now - file_server.created_at) > LINK_EXPIRE_TIME_FOR_FILE_SERVER_IN_SECONDS
          render json: {message: "Link has expired"}, status: :not_found
        else
          file_path = FileServer.temp_storage_file_path(file_server.filename)
          if File.exists?(file_path)
            send_file file_path
          else
            render plain: {message: "File not found"}, status: :not_found
          end
        end
      else
        render json: {message: "Link has expired"}, status: :not_found
      end
    else
      render json: {message: "Identifier not correct"}, status: :bad_request
    end
  end

end