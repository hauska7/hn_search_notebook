class SearchQuery < ApplicationRecord
  validates :query, presence: true

  has_many :search_results

end