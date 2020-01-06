class ResultsInNotebook < ApplicationRecord
  belongs_to :search_result
  belongs_to :search_notebook
end