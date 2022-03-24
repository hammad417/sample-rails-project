# frozen_string_literal: true

module ActiveAdmin
  class DocumentPolicy < ApplicationPolicy
    def index?
      super_admin? || admin?
    end

    def show?
      (super_admin? || admin?) && record.active?
    end

    def create?
      super_admin?
    end

    def new?
      super_admin?
    end

    def update?
      # only document in draft mode can be updated
      (super_admin? || editor? ) && record.draft? && show?
    end

    def edit?
      update?
    end

    def destroy?
      user.super_admin?
    end

    def download?
      user.super_admin? || admin?
    end
  end
end
