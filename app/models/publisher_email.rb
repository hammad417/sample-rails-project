# frozen_string_literal: true

# == Schema Information
#
# Table name: publisher_emails
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PublisherEmail < ApplicationRecord
  validates :email, presence: true
end
