# frozen_string_literal: true

ActiveAdmin.register Document do

  permit_params do
    permitted = %i[mode document_type classification document_number issuer recipient
                   recipient_id_type issue_date effective_date expiration_date description reference_type
                   reference_number other_reference_type other_reference_number issuer_sign_name_1 issuer_sign_datetime_1 issuer_sign_name_2 issuer_sign_datetime_2
                   recipient_sign_name_1 recipient_sign_datetime_1 recipient_sign_name_2
                   recipient_sign_datetime_2 witness_sign_name witness_sign_datetime]
    # permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end

  remove_filter :filename, :file_path, :is_temp, :delivery_channel, :sender, :identifier, :prefix, :identifier_key, :effective_date, :expiration_date, :description, :reference_type,
                :other_reference_type, :issuer_signature_1, :issuer_sign_name_1,
                :issuer_sign_datetime_1, :issuer_signature_2, :issuer_sign_name_2, :issuer_sign_datetime_2, :recipient_signature_1,
                :recipient_sign_name_1, :recipient_sign_datetime_1, :recipient_signature_2, :recipient_sign_name_2,
                :recipient_sign_datetime_2, :witness_signature, :witness_sign_name, :witness_sign_datetime, :archive_documents, :versions, :archived,
                :issuer_signature_1_filename, :issuer_signature_2_filename, :recipient_signature_1_filename, :recipient_signature_2_filename, :witness_signature_filename, :should_send_notification

  preserve_default_filters!
  filter :mode, as: :select, collection: Document::DOCUMENT_MODES
  filter :filter_document_type, as: :select, collection: DocumentType.all.pluck(:name) + ["OTHER"], label: 'Document Type',filters: [:eq]
  filter :classification, as: :select, collection: Document::DOCUMENT_CLASSIFICATION
  filter :recipient_id_type, as: :select, collection: Document::RECIPIENT_ID_TYPE

  sidebar "Documents", only: [:show] do
    ul do
      li link_to "Archived Documents", admin_document_archive_documents_path(resource) if authorized?(:index, ArchiveDocument)
    end
  end

  scope :active, default: true


  index do
    column :id
    column :document_number
    column :mode
    column :document_type
    column :classification
    column :issue_date
    column :issuer
    column :recipient

    actions defaults: false do |resource|
      if controller.action_methods.include?('show') && authorized?(ActiveAdmin::Auth::READ, resource)
        item 'View', resource_path(resource), class: 'view_link member_link', title: 'View'
      end
      if controller.action_methods.include?('edit') && authorized?(ActiveAdmin::Auth::UPDATE, resource)
        item 'Enrich', edit_resource_path(resource), class: 'edit_link member_link', title: 'Enrich'
      end
      # if controller.action_methods.include?('destroy') && authorized?(ActiveAdmin::Auth::DESTROY,
      #                                                                 resource) && !resource.archived?
      #   item 'Archive', resource_path(resource), class: 'delete_link member_link', title: 'Archive',
      #                                            method: :delete, data: { confirm: 'Are you sure you want to do this?' }
      # end
      if authorized?(:download, resource) && resource.downloadable?
        item 'Download', download_admin_document_path(resource), class: 'edit_link member_link', title: 'Download'
      end
      item 'Download attributes', download_attributes_admin_document_path(resource), class: 'edit_link member_link', title: 'Document attributes'
    end
  end

  # Do not show action item on show page
  config.action_items.delete_if do |item|
    item.display_on?(:show)
  end
  show do # rubocop:disable all
    attributes_table do
      row "document file" do |resource|
        (authorized?(:download, resource) && resource.downloadable?) ? link_to(resource.filename, download_admin_document_path(resource)) : "No file attached"
      end
      row :mode
      row :archived
      row :document_type
      row :classification
      row :document_number

      row :issuer
      row :recipient
      row :recipient_id_type

      row :issue_date
      row :effective_date
      row :expiration_date

      row :description

      row :reference_type
      row :reference_number

      row :other_reference_type
      row :other_reference_number

      row :issuer_signature_1 do |d|
        signature_view(signature: d.issuer_signature_1, filename: d.issuer_signature_1_filename)
      end
      row :issuer_signature_1_filename
      row :issuer_sign_name_1
      row :issuer_sign_datetime_1

      row :issuer_signature_2 do |d|
        signature_view(signature: d.issuer_signature_2, filename: d.issuer_signature_2_filename)
      end
      row :issuer_signature_2_filename
      row :issuer_sign_name_2
      row :issuer_sign_datetime_2

      row :recipient_signature_1 do |d|
        signature_view(signature: d.recipient_signature_1, filename: d.recipient_signature_1_filename)
      end
      row :recipient_signature_1_filename
      row :recipient_sign_name_1
      row :recipient_sign_datetime_1

      row :recipient_signature_2 do |d|
        signature_view(signature: d.recipient_signature_2, filename: d.recipient_signature_2_filename)
      end
      row :recipient_signature_2_filename
      row :recipient_sign_name_2
      row :recipient_sign_datetime_2

      row :witness_signature do |d|
        signature_view(signature: d.witness_signature, filename: d.witness_signature_filename)
      end
      row :witness_signature_filename
      row :witness_sign_name
      row :witness_sign_datetime
    end
    render 'update_history'
  end

  controller do
    def create # rubocop:disable all
      @resource = Document.new(permitted_params[:document])
      @resource.assign_file_attributes(params[:document][:document_file])
      @resource.assign_signature_attributes(params[:document])
      if @resource.save
        FileUploadService.new(key: @resource.file_path, file: params[:document][:document_file].tempfile.path).upload
        Document.create_audit_trail(action: 'create', user: current_admin.email, document_ids: @resource.id)
        PinpointNotificationService.new(@resource).call
        redirect_to admin_documents_path
      else
        render :new
      end
    end

    def update(options = {}, &block)
      @resource = resource
      super do |success, failure|
        block.call(success, failure) if block
        success.html {
          if params[:document][:document_file].present?
            FileUploadService.new(key: resource.file_path, file: params[:document][:document_file].tempfile.path).upload
          end
          Document.create_audit_trail(action: 'enrich', user: current_admin.email, document_ids: @resource.id)
          redirect_to admin_documents_path
        }
        failure.html {
          render :edit
        }
      end
    end

    def destroy
      resource.archived!
      redirect_to admin_documents_path
    end
  end

  before_update do |resource|
    resource.assign_file_attributes(params[:document][:document_file])
    resource.assign_signature_attributes(params[:document])
  end

  after_update do |resource|
    if params[:document][:document_file].present? && resource.valid?
      resource.generate_archive_document
    end
  end

  form do |f|
    render partial: 'admin/shared/errors'
    f.inputs do
      f.input :document_file, as: :file, hint: "Valid file formats #{Document::DOCUMENT_FILE_VALID_FORMATS.join(",")}"
      f.input :mode, as: :select, collection: Document::DOCUMENT_MODES, prompt: "Select mode"
      unless f.object.persisted?
        f.input :document_type, as: :select, collection: ["OTHER"] + DocumentType.all.pluck(:name),
                include_blank: false, input_html: {class: "document_type"}
        f.text_field :document_type, {class:"other_document_type", disabled: true}
      end

      f.input :description
      f.input :classification, as: :select, collection: Document::DOCUMENT_CLASSIFICATION, prompt: "Select classification"

      f.input :document_number unless f.object.persisted?

      f.input :issuer unless f.object.persisted?
      f.input :recipient unless f.object.persisted?
      unless f.object.persisted?
        f.input :recipient_id_type, as: :select, collection: Document::RECIPIENT_ID_TYPE,
                prompt: "Select recipient id type"
      end

      f.input :issue_date, as: :datetime_picker unless f.object.persisted?
      f.input :effective_date, as: :datetime_picker
      f.input :expiration_date, as: :datetime_picker


      f.input :reference_type, as: :select, collection: DocumentType.all.pluck(:name) + ["OTHER"], include_blank: true unless f.object.persisted?
      f.input :reference_number unless f.object.persisted?

      f.input :other_reference_type, as: :select, collection: DocumentType.all.pluck(:name) + ["OTHER"], include_blank: true
      f.input :other_reference_number

      render partial: 'admin/documents/radio_buttons', locals: {input: "issuer_signature_1"}
      f.input :issuer_signature_1, as: :file, input_html: {class: 'base64_file_input d-none'} unless f.object.persisted?
      f.input :issuer_signature_1_base64, as: :text, label: false, input_html: {class: 'base64_raw_input d-none'} unless f.object.persisted?
      f.input :issuer_sign_name_1 unless f.object.persisted?
      f.input :issuer_sign_datetime_1, as: :datetime_picker unless f.object.persisted?

      render partial: 'admin/documents/radio_buttons', locals: {input: "issuer_signature_2"}
      f.input :issuer_signature_2, as: :file, input_html: {class: 'base64_file_input d-none'} unless f.object.persisted?
      f.input :issuer_signature_2_base64, as: :text, label: false, input_html: {class: 'base64_raw_input d-none'} unless f.object.persisted?
      f.input :issuer_sign_name_2 unless f.object.persisted?
      f.input :issuer_sign_datetime_2, as: :datetime_picker unless f.object.persisted?

      render partial: 'admin/documents/radio_buttons', locals: {input: "recipient_signature_1"}
      f.input :recipient_signature_1, as: :file, input_html: {class: 'base64_file_input d-none'} unless f.object.persisted?
      f.input :recipient_signature_1_base64, as: :text, label: false, input_html: {class: 'base64_raw_input d-none'} unless f.object.persisted?
      f.input :recipient_sign_name_1 unless f.object.persisted?
      f.input :recipient_sign_datetime_1, as: :datetime_picker unless f.object.persisted?

      render partial: 'admin/documents/radio_buttons', locals: {input: "recipient_signature_2"}
      f.input :recipient_signature_2, as: :file, input_html: {class: 'base64_file_input d-none'} unless f.object.persisted?
      f.input :recipient_signature_2_base64, as: :text, label: false, input_html: {class: 'base64_raw_input d-none'} unless f.object.persisted?
      f.input :recipient_sign_name_2 unless f.object.persisted?
      f.input :recipient_sign_datetime_2, as: :datetime_picker unless f.object.persisted?

      render partial: 'admin/documents/radio_buttons', locals: {input: "witness_signature"}
      f.input :witness_signature, as: :file, input_html: {class: 'base64_file_input d-none'}
      f.input :witness_signature_base64, as: :text, label: false, input_html: {class: 'base64_raw_input d-none'}
      f.input :witness_sign_name
      f.input :witness_sign_datetime, as: :datetime_picker
    end
    f.actions
  end

  member_action :download, method: :get do
    document = Document.find(params[:id])
    if File.exists?(document.file_path)
      send_file document.file_path
    else
      redirect_to admin_documents_path, alert: 'File does not exist'
    end
  end

  member_action :download_attributes, method: :get do
    document = Document.find(params[:id])
    document_serializer = DocumentSerializer.new(document)
    data = JSON.pretty_generate(document_serializer.as_json)
    send_data data, :type => 'application/json; header=present', :disposition => "attachment; filename=document_attributes.json"
  end
end
