# == Schema Information
#
# Table name: versions
#
#  id             :bigint           not null, primary key
#  event          :string           not null
#  item_type      :string
#  object         :text
#  object_changes :json
#  whodunnit      :string
#  {:null=>false} :string
#  created_at     :datetime
#  item_id        :bigint           not null
#
# Indexes
#
#  index_versions_on_item_type_and_item_id  (item_type,item_id)
#
class Version < ApplicationRecord

end
