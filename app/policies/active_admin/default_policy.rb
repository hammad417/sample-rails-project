# frozen_string_literal: true

module ActiveAdmin
  class DefaultPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope
      end
    end

    def index?
      admin?
    end
  end
end
