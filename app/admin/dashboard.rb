# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do

    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      column do
        panel "Account Actions" do
          ul do
            li link_to("Change password", edit_admin_registration_path)
          end
        end
      end
    end
  end
end
