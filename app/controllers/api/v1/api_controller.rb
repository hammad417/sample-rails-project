class Api::V1::ApiController < ActionController::API
  include Pagy::Backend

  before_action :verify_authorized

  after_action { pagy_headers_merge(@pagy) if @pagy }

  def verify_authorized
    client_id_header = request.headers["HTTP_CLIENT_ID"]
    secret_header = request.headers["HTTP_SECRET"]
    access_token_header = request.headers["HTTP_ACCESS_TOKEN"]
    app_authorization = AppAuthorization.find_by(client_id: client_id_header)

    unless app_authorization && secret_header == app_authorization.secret && access_token_header == app_authorization.access_token
      unauthorized
    end
  end

  def client_id_header
    request.headers["HTTP_CLIENT_ID"]
  end

  def unauthorized(message = nil)
    render json: {
        message: message ? message : "You are not authorized to perform this action"
    }, status: :unauthorized
  end

  def render_resource_errors(resource, status = 400)
    render json: {
        errors: resource.errors.full_messages.join(".")
    }, status: status
  end

  def record_not_found
    render json: {
        error: "Record not found with given id"
    }, status: 404
  end

end