class SearchNotebook < ApplicationRecord
  validate :title, presence: true

end