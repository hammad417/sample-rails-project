# == Schema Information
#
# Table name: audit_trails
#
#  id            :bigint           not null, primary key
#  action        :string
#  document_ids  :string
#  resource_type :string
#  user          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class AuditTrail < ApplicationRecord
  RESOURCE_TYPES = %w[Document User].freeze
  RESOURCE_ACTIONS = ["sign in", "sign out", "create", "enrich", "add", "edit", "change", "delete"].freeze
end
