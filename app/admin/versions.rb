# ActiveAdmin.register Version do
#
#   menu label: "Document Audit Trails"
#
#   config.filters = false
#
#   index do
#     column :id do |v|
#       v.item_id
#     end
#     column :event
#     column :user do |v|
#       v.whodunnit
#     end
#     column :changes do |v|
#       v.object_changes
#     end
#
#     column :time do |v|
#       v.created_at
#     end
#   end
#
# end
