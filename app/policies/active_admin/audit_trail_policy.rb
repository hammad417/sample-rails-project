# frozen_string_literal: true

module ActiveAdmin
  class AuditTrailPolicy < ApplicationPolicy

    def index?
      user.super_admin?
    end
  end
end
