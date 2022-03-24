# frozen_string_literal: true

module ActiveAdmin
  class VersionPolicy < ApplicationPolicy

    def index?
      user.super_admin?
    end

  end
end
