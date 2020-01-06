class SearchResult < ApplicationRecord
  validates :hn_login, presence: true
  validates :hn_object_id, presence: true

  belongs_to :search_query

  scope :with_hn_object_id, -> (hn_object_ids) { where(hn_object_id: hn_object_ids) }

  def present
    result = "#{url} #{hn_login}"
    if result.size > 30
      result = result[0...30]
      result << "..."
    end
    result
  end
end