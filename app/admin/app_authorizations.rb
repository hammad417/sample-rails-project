ActiveAdmin.register AppAuthorization do

  config.filters = false

  permit_params :client_id

  index do
    id_column
    column("client_id") { |r| r.client_id }
    column :secret
    column :access_token
    column :refresh_token
    actions do |resource|
      if authorized?(:refresh_token, resource)
        item 'Refresh token', refresh_token_admin_app_authorization_path(resource), method: :post, class: 'edit_link member_link', title: 'Refresh token'
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :client_id, label: "Client Id"
    end
    f.actions
  end

  controller do
    def create # rubocop:disable all
      @resource = AppAuthorization.new(permitted_params[:app_authorization])
      @resource.generate_secret_and_tokens
      if @resource.save
        redirect_to admin_app_authorizations_path
      else
        render :new
      end
    end
  end

  member_action :refresh_token, method: :post do
    authorization = AppAuthorization.find(params[:id])
    authorization.update(access_token: SecureRandom.hex(AppAuthorization::ACCESS_TOKEN_HEX_LENGTH))
    redirect_to admin_app_authorizations_path, notice: "Token refreshed"
  end
end