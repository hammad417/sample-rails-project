# frozen_string_literal: true

module ActiveAdmin
  class PagePolicy < ApplicationPolicy
    def show?
      case record.name
      when 'Dashboard'
        admin?
      when "App Authorization"
        super_admin?
      else
        false
      end
    end

    def generate_keys?
      case record.name
      when "App Authorization"
        super_admin?
      else
        false
      end
    end

    def refresh_token?
      generate_keys?
    end
  end
end
