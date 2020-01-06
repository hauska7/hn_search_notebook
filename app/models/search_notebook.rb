class SearchNotebook < ApplicationRecord
  validates :title, presence: true

  has_many :results_in_notebook
  has_many :search_results, through: :results_in_notebook

  def present
    title
  end
end