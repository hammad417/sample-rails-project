# ActiveAdmin.register AdminAuditTrail do
#   menu label: "Admin Audit Trail"
#
#   index title: "Audit Trail" do
#     selectable_column
#     id_column
#     column :email
#     column :roles_titles
#     column :super_admin
#     column :session_time do |a|
#       ChronicDuration.output((a.logout_time - a.login_time).round) if a.logout_time.present?
#     end
#     column :login_time
#     column :logout_time
#   end
#
# end
