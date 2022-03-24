class Api::V1::AppAuthorizationsController < Api::V1::ApiController

  def refresh_token
    client_id_header = request.headers["HTTP_CLIENT_ID"]
    app_authorization = AppAuthorization.find_by(client_id: client_id_header)

    if app_authorization && params[:refresh_token] == app_authorization.refresh_token
      app_authorization.update_access_token
      render json: AppAuthorizationSerializer.new(app_authorization), status: :ok
    else
      unauthorized
    end
  end
end