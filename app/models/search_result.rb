class SearchResult < ApplicationRecord
  validates :hn_login, presence: true

  belongs_to :search_query

  def present
    "#{hn_login} #{url}"
  end
end