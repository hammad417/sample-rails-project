# frozen_string_literal: true

module ActiveAdmin
  class ArchiveDocumentPolicy < ApplicationPolicy
    def index?
      user.super_admin?
    end

    def download?
      index?
    end
  end
end
