# frozen_string_literal: true

module ActiveAdmin
  class DashboardPolicy < ApplicationPolicy
    def index?
      admin?
    end
  end
end
