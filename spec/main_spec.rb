require "rails_helper"

describe MainController, type: :controller do
  render_views

  context "create_search_notebook" do
    it "create empty search_notebook" do
      expect do
        post :create_search_notebook, params: { title: "Superheroes" }
      end.to_change { SearchNotebook.count }.by 1

      search_notebook = SearchNotebook.last
      expect(search_notebook.title).to eq "Superheroes"
    end
  end

  context "index_search_notebook" do
    it "list search notebooks" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!
      cartoons = SearchNotebook.new
      cartoons.title = "Cartoons"
      cartoons.save!

      get :index_search_notebook

      expect(response).to have_http_status(200)
      expect(assigns(:search_notebooks)).to match_array [superheroes, cartoons]
    end
  end

  context "destroy_search_notebook" do
    it "destroy search notebook" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      dc_superheroes_query = SearchQuery.new
      dc_superheroes_query.query = "dc superheroes"
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!
      wonder_woman = SearchResult.new
      wonder_woman.hn_login = "eat_veggies"
      wonder_woman.url = "http://wonderwoman.com"
      wonder_woman.author_karma_points = 1140
      wonder_woman.tags = ["wonder_woman"]
      wonder_woman.search_query = dc_superheroes_query
      wonder_woman.save!

      # todo: add another search notebook and have a sharde search result
      expect(SearchNotebook.count).to eq 1
      expect(SearchQuery.count).to eq 1
      expect(SearchResult.count).to eq 2

      delete :destroy_search_notebook, params: { id: superheroes.id }

      expect(SearchNotebook.count).to eq 0
      expect(SearchQuery.count).to eq 1
      expect(SearchResult.count).to eq 0
    end
  end

  context "remove_search_result_from_search_notebook" do
    it "" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      dc_superheroes_query = SearchQuery.new
      dc_superheroes_query.query = "dc superheroes"
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!

      # add batman to superheroes

      post :remove_search_result_from_search_notebook,
           params: { search_notebook_id: superheroes.id, search_result_id: batman.id }

      # expect batman not to be in superheroes
    end
  end

  context "HN search" do
    it "search HN" do
      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      wonder_woman = SearchResult.new
      wonder_woman.hn_login = "eat_veggies"
      wonder_woman.url = "http://wonderwoman.com"
      wonder_woman.author_karma_points = 1140
      wonder_woman.tags = ["wonder_woman"]

      get :search_hackernews, params: { query: "Superheroes" }

      expect(response).to have_http_status(200)
      expect(assigns(:search_results)).to match_array [batman, wonder_woman]
      search_query = SearchQuery.last
      expect(search_query.query).to eq "Superheroes"
      expect(search_query.total_hit_count).to eq 2
      search_results = search_query.search_results.to_a
      expect(search_results).to match_array [batman, wonder_woman]
    end

    it "pagination" do
      pending
    end
  end

  context "show_search_notebook" do
    it "empty" do
      pending
    end

    it "with content" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      dc_superheroes_query = SearchQuery.new
      dc_superheroes_query.query = "dc superheroes"
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!
      wonder_woman = SearchResult.new
      wonder_woman.hn_login = "eat_veggies"
      wonder_woman.url = "http://wonderwoman.com"
      wonder_woman.author_karma_points = 1140
      wonder_woman.tags = ["wonder_woman"]
      wonder_woman.search_query = dc_superheroes_query
      wonder_woman.save!

      get :show_search_notebook, params: { id: superheroes.id }

      expect(response).to have_http_status(200)
      expect(assigns(:search_results)).to match_array [batman, wonder_woman]
    end
  end

  context "add_search_result_to_search_notebook" do
    it "add search result to search notebook" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      dc_superheroes_query = SearchQuery.new
      dc_superheroes_query.query = "dc superheroes"
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!

      post :add_search_result_to_search_notebook,
           params: { search_notebook_id: superheroes.id, search_result_id: batman.id }

      search_result = superheroes.search_results.first
      expect(search_result).to eq batman
    end
  end

  context "statistics" do
    it "display" do
      get :statistics
    end
  end
end

describe "services" do
  it "clean search results" do
    superheroes = SearchNotebook.new
    superheroes.title = "Superheroes"
    superheroes.save!

    dc_superheroes_query = SearchQuery.new
    dc_superheroes_query.query = "dc superheroes"
    dc_superheroes_query.save!

    batman = SearchResult.new
    batman.hn_login = "shaklee3"
    batman.url = "http://batman.com"
    batman.author_karma_points = 1727
    batman.tags = ["batman"]
    batman.search_query = dc_superheroes_query
    batman.save!
    wonder_woman = SearchResult.new
    wonder_woman.hn_login = "eat_veggies"
    wonder_woman.url = "http://wonderwoman.com"
    wonder_woman.author_karma_points = 1140
    wonder_woman.tags = ["wonder_woman"]
    wonder_woman.search_query = dc_superheroes_query
    wonder_woman.save!

    # add batman to superheroes

    # run clean up

    # expect batman to saau and wonder woman to go
    expect(SearchResult.count).to eq 1
    expect(SearchResult.first!).to be batman
  end

  it "clean search queries" do
    # todo
  end
end