ActiveAdmin::Devise::SessionsController.class_eval do
  prepend_before_action :logout_activity, only: :destroy

  def after_sign_in_path_for(resource)
    # audit = AdminAuditTrail.create(email: resource.email, super_admin: resource.super_admin, login_time: DateTime.now,
    #                             roles_titles: resource.roles.pluck(:name).join(","), admin: resource)
    Admin.create_audit_trail(action: "sign in", user: current_admin.email)
    admin_dashboard_path
  end


  def logout_activity
    return  unless current_admin.present?
    Admin.create_audit_trail(action: "sign out", user: current_admin.email)
  end
end

ActiveAdmin::Devise::RegistrationsController.class_eval do
  prepend_after_action :password_edit_trail, only: :update

  def password_edit_trail
    return  unless current_admin.present?
    Admin.create_audit_trail(action: "change", user: current_admin.email, effected_user: current_admin.email)
  end
end