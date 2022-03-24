class Api::V1::DocumentsController < Api::V1::ApiController

  def get_document_list
    @pagy, @documents = pagy(Document.filter(filter_params).active)
    render json: DocumentSerializer.new(@documents), status: :ok
  end

  def create
    errors = []
    document_ids = []
    params[:documents].each do |doc|
      document = Document.new(create_permitted_params)
      document.assign_attributes_from_document_object_in_api(doc)
      if delivery_channel_sftp? || delivery_channel_email?
        document.skip_document_file_validations = true
        document.is_temp = true
        document.filename = get_file_name(doc)
      else
        document.assign_file_attributes_for_api(doc[:file])
      end
      document.assign_signature_attributes_for_api(params)
      document.should_send_notification = true

      if document.save
        #TODO: Handle email delivery channel later
        unless delivery_channel_sftp? || delivery_channel_email?
          # Create a copy of uploaded file, otherwise, it will be deleted after request finishes
          new_file_path = UniquePathForTempFile.new(file: doc[:file]).generate
          # create a background job for file conversion and upload
          DocumentConversionAndUploadJob.perform_async(document.id, new_file_path)
        end
        document_ids.push(document.id)
      else
        error_obj = {
            document_number: doc[:document_number],
            errors: document.errors.full_messages
        }
        errors.push(error_obj)
      end
    end

    if errors.present?
      render json: {errors: errors, document_ids: document_ids}, status: :bad_request
    else
      render json: {document_ids: document_ids}, status: :ok
    end
  end

  def update_documents
    documents = []
    params[:documents].each do |doc|
      document = Document.find_by(id: doc[:id], archived: false)
      next unless document.present?
      document.assign_signature_attributes_for_api(doc)
      document.assign_attributes(update_documents_permitted_params(document, doc))
      if document.changed?
        if document.save
          success_obj = {
              document_id: document.id,
              status_code: 200
          }
          success_obj.merge!(DocumentSerializer.new(document))
          documents.push(success_obj)
        else
          error_obj = {
              document_id: document.id,
              status_code: 400,
              errors: document.errors.full_messages
          }
          documents.push(error_obj)
        end
      else
        error_obj = {
            document_id: document.id,
            status_code: 400,
            errors: "Document not updated"
        }
        documents.push(error_obj)
      end
    end


    if documents.empty?
      render json: {message: "No document found"}, status: :bad_request
    else
      render json: {documents: documents}, status: :ok
    end

  end

  def replace_documents
    errors = []
    document_ids = []
    params[:documents].each do |doc|
      document = Document.find_by(id: doc[:id], archived: false)
      next unless (document.present? && doc[:file].present? && doc[:file].is_a?(ActionDispatch::Http::UploadedFile))
      document.assign_file_attributes_for_api(doc[:file])

      if document.save
        document.generate_archive_document
        # Create a copy of uploaded file, otherwise, it will be deleted after request finishes
        new_file_path = UniquePathForTempFile.new(file: doc[:file]).generate
        # create a background job for file conversion and upload
        DocumentConversionAndUploadJob.perform_async(document.id, new_file_path)
        document_ids.push(document.id)
      else
        error_obj = {
            document_number: doc[:document_number],
            errors: document.errors.full_messages
        }
        errors.push(error_obj)
      end
    end

    if errors.present?
      render json: {errors: errors, document_ids: document_ids}, status: :bad_request
    elsif document_ids.empty?
      render json: {message: "No document found"}, status: :bad_request
    else
      render json: {document_ids: document_ids}, status: :ok
    end
  end

  def remove_documents
    documents = Document.where(id: params[:document_ids],archived: false)
    documents.each do |document|
      document.update(archived: true)
    end

    if documents.pluck(:id).empty?
      render json: {message: "No document found"}, status: :bad_request
    else
      render json: {document_ids: documents.pluck(:id), message: "#{helpers.pluralize(documents.size, "Document")} removed successfully"}, status: :ok
    end
  end

  def get_documents
    documents = Document.where(id: params[:document_ids], archived: false)
    doc_array = []
    documents.each do |document|
      if document.file_path.present?
        doc = DocumentSerializer.new(document).serializable_hash
        fs = FileServer.create_unique_record(document)
        if fs.present?
          CopyFileToTempFileServerJob.perform_async(document.file_path, fs.filename)
          doc[:data][:attributes][:document_file_url] = serve_file_file_servers_url(identifier: fs.identifier)
        end

        doc_array.push(doc)
      end
    end

    if doc_array.empty?
      render json: {message: "No document found"}, status: :bad_request
    else
      render json: {documents: doc_array}, status: :ok
    end
  end

  private

  def create_permitted_params
    params.permit(:mode, :document_type, :delivery_channel, :sender, :identifier, :prefix, :identifier_key, :classification, :document_number, :issuer, :recipient,
                  :recipient_id_type, :issue_date, :effective_date, :expiration_date, :description, :reference_type,
                  :reference_number, :other_reference_type, :other_reference_number, :issuer_sign_name_1, :issuer_sign_datetime_1,
                  :issuer_sign_name_2, :issuer_sign_datetime_2, :recipient_sign_name_1, :recipient_sign_datetime_1, :recipient_sign_name_2,
                  :recipient_sign_datetime_2, :witness_sign_name, :witness_sign_datetime)
  end

  def update_documents_permitted_params(document, doc_params)
    if document.final?
      # only enrichable/optional attributes
      params_array = [:classification, :effective_date, :expiration_date, :description, :reference_type,
                      :reference_number, :other_reference_type, :other_reference_number, :issuer_sign_name_1, :issuer_sign_datetime_1,
                      :issuer_sign_name_2, :issuer_sign_datetime_2, :recipient_sign_name_1, :recipient_sign_datetime_1, :recipient_sign_name_2,
                      :recipient_sign_datetime_2, :witness_sign_name, :witness_sign_datetime]
    else
      params_array = [:mode, :classification, :issuer, :issue_date, :effective_date, :expiration_date, :description, :reference_type,
                      :reference_number, :other_reference_type, :other_reference_number, :issuer_sign_name_1, :issuer_sign_datetime_1,
                      :issuer_sign_name_2, :issuer_sign_datetime_2, :recipient_sign_name_1, :recipient_sign_datetime_1, :recipient_sign_name_2,
                      :recipient_sign_datetime_2, :witness_sign_name, :witness_sign_datetime]
    end
    doc_params.permit(params_array)
  end

  def filter_params
    params.slice(:mode, :document_type, :classification, :reference_number, :reference_type, :other_reference_number, :other_reference_type,
                 :document_number, :recipient, :issuer, :issue_date_from, :issue_date_to)
  end

  def delivery_channel_sftp?
    params[:delivery_channel].present? && params[:delivery_channel].downcase == "sftp"
  end

  def delivery_channel_email?
    params[:delivery_channel].present? && params[:delivery_channel].downcase == "email"
  end

  def get_file_name(document_obj)
    filename = ''
    if delivery_channel_sftp?
      if params[:identifier] == "filename"
        filename = "#{params[:prefix]}#{document_obj[params[:identifier_key]]}"
      end
    end
    filename
  end

end