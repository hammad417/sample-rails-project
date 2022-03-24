# frozen_string_literal: true

# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  super_admin            :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#
class Admin < ApplicationRecord
  rolify(dependent: :destroy_all)
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :admin_audit_trails, dependent: :destroy

  def self.create_audit_trail(action:, user:, effected_user: nil)
    AuditTrail.create(resource_type: "User", action: action, user: user, document_ids: effected_user)
  end

  def assign_roles(roles_array)
    permissions = roles_array.reject(&:empty?)
    self.roles = []
    permissions.each { |p| add_role(p.to_sym) }
  end

  def roles_changed?(roles_array)
    permissions = roles_array.reject(&:empty?)
    self.roles.pluck(:name) == permissions ? false : true
  end
end
