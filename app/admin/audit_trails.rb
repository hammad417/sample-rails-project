ActiveAdmin.register AuditTrail do

  preserve_default_filters!
  filter :resource_type, as: :select, collection: AuditTrail::RESOURCE_TYPES
  filter :action, as: :select, collection: AuditTrail::RESOURCE_ACTIONS

  index do
    column :resource_type
    column :action
    column "Resource Id", :document_ids
    column :user
    column "Time",:created_at
  end

end
