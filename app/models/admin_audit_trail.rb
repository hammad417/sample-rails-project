# == Schema Information
#
# Table name: admin_audit_trails
#
#  id           :bigint           not null, primary key
#  email        :string
#  login_time   :datetime
#  logout_time  :datetime
#  roles_titles :string
#  super_admin  :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  admin_id     :bigint
#
# Indexes
#
#  index_admin_audit_trails_on_admin_id  (admin_id)
#
class AdminAuditTrail < ApplicationRecord
  belongs_to :admin
end
