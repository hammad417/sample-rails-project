# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized, unless: -> { active_admin_controller? || devise_controller? }
  after_action :verify_policy_scoped, only: :index, unless: -> { active_admin_controller? || devise_controller? }

  # skip_after_action :verify_authorized, if: -> { is_a?(ActiveAdmin::Devise::RegistrationsController) || devise_controller?  }

  def active_admin_controller?
    is_a?(ActiveAdmin::BaseController) || is_a?(ActiveAdmin::Devise::SessionsController) || is_a?(ActiveAdmin::Devise::PasswordsController) || is_a?(ActiveAdmin::Devise::RegistrationsController)
  end

  def user_for_paper_trail
    current_admin.present? ? current_admin.email : 'Unknown'
  end
end
