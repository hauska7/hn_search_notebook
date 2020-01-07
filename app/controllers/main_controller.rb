class MainController < ApplicationController
  def index_search_notebooks
    @search_notebooks = SearchNotebook.all.order(created_at: :desc).to_a
    @search_notebook = SearchNotebook.new
  end

  def show_search_notebook
    @search_notebook = SearchNotebook.find(params["id"])
    @search_results = @search_notebook.search_results.order(created_at: :desc).to_a
  end

  def show_statistics
    @items = Queries.query("search_queries_statistics")
  end

  def search_hackernews
    query_string = params["query"]

    if params["search_query_id"]
      search_query = SearchQuery.find(params["search_query_id"])
    else
      search_query = SearchQuery.new
      search_query.query = query_string
    end

    unless search_query.valid?
      flash[:alert] = search_query.errors.full_messages.first
      return redirect_to :root
    end

    result = ExternalRequests.search_hn(query_string, params["page"])
    if result.failure?
      flash[:alert] = "Something went wrong with searching HackerNews."
      return redirect_to :root
    end

    data = result.data
    @pagination = result.pagination

    search_query.total_hits_count = @pagination.total_count

    hits = data["hits"]
    hn_object_ids = hits.map { |hit| hit["objectID"] }
    already_persisted_search_results = search_query.search_results.with_hn_object_id(hn_object_ids).to_a

    @search_results = hits.map do |hit|
      search_result = already_persisted_search_results.find { |sr| sr.hn_object_id == hit["objectID"] }
      unless search_result
        search_result = SearchResult.new
        search_result.hn_login = hit["author"]
        search_result.hn_object_id = hit["objectID"]
        search_result.url = hit["url"].presence
        # todo: handle tags from user input
        search_result.tags = ["story"]
        search_result.search_query = search_query
      end
      search_result
    end

    ActiveRecord::Base.transaction do
      search_query.save!
      @search_results.select(&:new_record?).each(&:save!)
    end

    Service.schedule_fetching_author_karma(@search_results)

    @search_notebooks = SearchNotebook.all.to_a
    @base_query_string = "?query=#{query_string}&search_query_id=#{search_query.id}"
  end

  def create_search_notebook
    search_notebook = SearchNotebook.new
    search_notebook.title = params.dig("search_notebook", "title")

    if search_notebook.save
      redirect_to show_search_notebook_path(search_notebook)
    else
      flash[:alert] = search_notebook.errors.full_messages.first
      redirect_to index_search_notebooks_path
    end
  end

  def destroy_search_notebook
    search_notebook = SearchNotebook.find(params["id"])

    ActiveRecord::Base.transaction do
      ResultsInNotebook.where(search_notebook: search_notebook).delete_all
      search_notebook.destroy!
    end

    flash[:notice] = "Search notebook deleted succesfully."
    redirect_to index_search_notebooks_path
  end

  def remove_search_result_from_search_notebook 
    search_notebook = SearchNotebook.find(params["search_notebook_id"])
    search_result = SearchResult.find(params["search_result_id"])

    ResultsInNotebook.where(search_notebook: search_notebook, search_result: search_result).delete_all
    
    flash[:notice] = "Search result removed succesfully."
    redirect_to show_search_notebook_path(search_notebook)
  end

  def add_search_result_to_search_notebook
    if params["mode"] == "ajax"
      search_notebook = SearchNotebook.find(params["search_notebook_id"])
      search_result = SearchResult.find(params["search_result_id"])

      result = Service.add_result_to_notebook(search_notebook, search_result)
      fail unless result.success?

      render status: 200, json: {}
    else fail
    end
  end
end