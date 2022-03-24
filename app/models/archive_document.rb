# == Schema Information
#
# Table name: archive_documents
#
#  id          :bigint           not null, primary key
#  file_path   :string
#  filename    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
#
# Indexes
#
#  index_archive_documents_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
class ArchiveDocument < ApplicationRecord
  belongs_to :document

  def downloadable?
    self.filename.present? && self.file_path.present?
  end
end
