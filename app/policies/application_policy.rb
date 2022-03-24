# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def admin?
    user.present? && user.is_a?(Admin)
  end

  def super_admin?
    user.super_admin?
  end

  def editor?
    user.present? && user.has_role?(:editor)
  end

  def viewer?
    user.present? && user.has_role?(:viewer?)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
