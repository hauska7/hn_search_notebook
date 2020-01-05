class SearchQuery < ApplicationRecord
  validate :query, presence: true

end