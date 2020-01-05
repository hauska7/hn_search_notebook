class SearchResult < ApplicationRecord
  validate :hn_login, presence: true
  validate :url, presence: true
  validate :author_karma_points, presence: true

end