ActiveAdmin.register ArchiveDocument do
  belongs_to :document

  config.filters = false

  actions :index

  index title: 'Archive Documents'  do
    id_column
    column :document
    column :filename
    column :file_path

    actions defaults: false do |resource|
      link_to('Download', download_admin_document_archive_document_path(resource.document,resource)) if authorized?(:download, resource) && resource.downloadable?
    end
  end

  member_action :download, method: :get do
    archive_document = ArchiveDocument.find(params[:id])
    if File.exists?(archive_document.file_path)
      send_file archive_document.file_path
    else
      redirect_to admin_document_archive_documents_path, alert: 'Error while downloading file'
    end
  end

end
