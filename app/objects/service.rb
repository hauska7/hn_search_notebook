class Service
  class ResultSuccess
    def success?
      true
    end
  end

  def self.result_success
    ResultSuccess.new
  end

  def self.delete(object)
    if object.is_a?(SearchNotebook)
      ActiveRecord::Base.transaction do
        ResultsInNotebook.where(search_notebook: object).delete_all
        object.destroy!
      end
    else fail
    end
    result_success
  end

  def self.add_result_to_notebook(notebook, results)
    results = Array(results)

    ActiveRecord::Base.transaction do
      results.each do |result|
        association = ResultsInNotebook.new
        association.search_result = result
        association.search_notebook = notebook
        association.save!
      end
    end

    result_success
  end

  def self.schedule_fetching_author_karma(search_results)
    # todo
    # since author karma is not available in the single request made for stories
    # and it seems at first glance that hn API only allowes single user fetch per request
    # we might either dive in the algolia api docs and find if there is a solution to getting authors karma
    # more efficiently in terms of requests
    # or a simple solution would be to fetch author karma in sidekiq (author karma is unavailable for request response)
  end
end