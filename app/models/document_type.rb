# frozen_string_literal: true

# == Schema Information
#
# Table name: document_types
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class DocumentType < ApplicationRecord
  validates :name, presence: true
end
