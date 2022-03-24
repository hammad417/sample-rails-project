# frozen_string_literal: true

ActiveAdmin.register Admin do # rubocop:disable all
  includes :roles

  permit_params :email, :super_admin

  # config.action_items[0] = ActiveAdmin::ActionItem.new only: :index do
  #   link_to "New user", new_admin_admin_path
  # end

  index do
    id_column
    column :email
    column :roles do |u|
      u.roles.map { |r| r.name.to_s }.join(',')
    end
    column :super_admin
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :email
      row :roles do |u|
        u.roles.map { |r| r.name.to_s }.join(',')
      end
      row :sign_in_count
      row :created_at
    end
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email, input_html: {readonly: f.object.id.present?}
      f.input :password
      f.input :super_admin
      f.input :permissions, as: :check_boxes, collection: Role::ROLES.map { |r|
        [r.to_s.capitalize, r, {checked: f.object.has_role?(r)}]
      }
    end
    f.actions do
      f.action :submit, label: "Save User", url: admin_admins_path
      f.action :cancel, label: "Cancel", wrapper_html: {class: 'cancel'}
    end
  end

  controller do
    def create # rubocop:disable all
      generated_password = params[:admin][:password]
      @admin = Admin.new(email: params[:admin][:email], password: params[:admin][:password],
                         password_confirmation: params[:admin][:password], super_admin: params[:admin][:super_admin])
      if @admin.save
        @admin.assign_roles(params[:admin][:permissions])
        Admin.create_audit_trail(action: "add", user: current_admin.email, effected_user: @admin.email)
        AdminMailer.account_creation(@admin.id, generated_password).deliver_later
        redirect_to admin_admins_path
      else
        render :new
      end
    end

    def update
      resource.assign_attributes(permitted_params[:admin])
      if params[:admin][:password].blank?
        params[:admin].delete(:password)
      else
        resource.assign_attributes(password: params[:admin][:password],
                        password_confirmation: params[:admin][:password])
      end
      if resource.save
        if params[:admin][:password].present?
          Admin.create_audit_trail(action: "change", user: current_admin.email, effected_user: resource.email)
        end
        if resource.roles_changed?(params[:admin][:permissions])
          Admin.create_audit_trail(action: "edit", user: current_admin.email, effected_user: resource.email)
        end
        resource.assign_roles(params[:admin][:permissions])
        redirect_to admin_admin_path(resource)
      else
        render :edit
      end
    end
  end

  after_destroy do |resource|
    Admin.create_audit_trail(action: "delete", user: current_admin.email, effected_user: resource.email)
  end
end
