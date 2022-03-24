# frozen_string_literal: true

module ActiveAdmin
  class AppAuthorizationPolicy < ApplicationPolicy

    def index?
      user.super_admin?
    end

    def create?
      index?
    end

    def new?
      index?
    end

    def refresh_token?
      index?
    end

    def destroy?
      index?
    end
  end
end
