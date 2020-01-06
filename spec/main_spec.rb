require "rails_helper"

describe MainController, type: :controller do
  render_views

  context "create_search_notebook" do
    it "success" do
      expect do
        post :create_search_notebook, params: { search_notebook: { title: "Superheroes" } }
      end.to change { SearchNotebook.count }.by 1

      search_notebook = SearchNotebook.last
      expect(search_notebook.title).to eq "Superheroes"
    end

    it "invalid title" do
      expect do
        post :create_search_notebook
      end.to change { SearchNotebook.count }.by 0
    end
  end

  context "index_search_notebooks" do
    it "list search notebooks" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!
      cartoons = SearchNotebook.new
      cartoons.title = "Cartoons"
      cartoons.save!

      get :index_search_notebooks

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
      dc_superheroes_query.total_hits_count = 0
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.hn_object_id = "1"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!
      wonder_woman = SearchResult.new
      wonder_woman.hn_login = "eat_veggies"
      wonder_woman.hn_object_id = "2"
      wonder_woman.url = "http://wonderwoman.com"
      wonder_woman.author_karma_points = 1140
      wonder_woman.tags = ["wonder_woman"]
      wonder_woman.search_query = dc_superheroes_query
      wonder_woman.save!

      Service.add_result_to_notebook(superheroes, [batman, wonder_woman])

      # todo: add another search notebook and have a shared search result
      expect(SearchNotebook.count).to eq 1
      expect(SearchQuery.count).to eq 1
      expect(SearchResult.count).to eq 2
      expect(ResultsInNotebook.count).to eq 2

      post :destroy_search_notebook, params: { id: superheroes.id }

      expect(SearchNotebook.count).to eq 0
      expect(SearchQuery.count).to eq 1
      expect(SearchResult.count).to eq 2
      expect(ResultsInNotebook.count).to eq 0
    end
  end

  context "remove_search_result_from_search_notebook" do
    it "success" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      dc_superheroes_query = SearchQuery.new
      dc_superheroes_query.query = "dc superheroes"
      dc_superheroes_query.total_hits_count = 0
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.hn_object_id = "3"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!

      Service.add_result_to_notebook(superheroes, batman)

      expect(superheroes.search_results.include?(batman)).to be true

      post :remove_search_result_from_search_notebook,
             params: { search_notebook_id: superheroes.id, search_result_id: batman.id }

      expect(superheroes.reload.search_results.include?(batman)).to be false

      # removing search result that is not in search notebook
      post :remove_search_result_from_search_notebook,
             params: { search_notebook_id: superheroes.id, search_result_id: batman.id }
      
      expect(response).to have_http_status(302)
    end
  end

  context "HN search" do
    it "basic search" do
      VCR.use_cassette("hn_search") do
        get :search_hackernews, params: { query: "wonder woman superman" }
      end

      expect(response).to have_http_status(200)
      search_query = SearchQuery.last
      expect(search_query.query).to eq "wonder woman superman"
      expect(search_query.total_hits_count).to eq 1
      search_results = search_query.search_results.to_a
      expect(assigns(:search_results)).to match_array search_results
      search_result = search_results.first
      expect(search_result.hn_login).to eq  "time_management"
      expect(search_result.author_karma_points).to eq  nil
      expect(search_result.url).to eq nil
      expect(search_result.tags).to match_array ["story"]
    end

    it "cant search empty query" do
      get :search_hackernews

      expect(response).to have_http_status(302)
    end

    context "pagination" do
      it "basic flow" do
        VCR.use_cassette("hn_search_paginated") do
          get :search_hackernews, params: { query: "superheroes", page: 3 }

          expect(response).to have_http_status(200)
          search_query = SearchQuery.last
          expect(search_query.query).to eq "superheroes"
          expect(search_query.total_hits_count).to eq 133
          expect(search_query.search_results.count).to eq 10
          expect(search_query.search_results.map(&:hn_login).include?("dy")).to be true

          # pagination uses the same search query
          expect(SearchQuery.count).to eq 1

          get :search_hackernews, params: { query: "superheroes", search_query_id: search_query.id, page: 4 }

          expect(SearchQuery.count).to eq 1
          expect(search_query.reload.search_results.count).to eq 20

          # reuse search results from pagination
          get :search_hackernews, params: { query: "superheroes", search_query_id: search_query.id, page: 4 }

          expect(search_query.reload.search_results.count).to eq 20
        end
      end
    end
  end

  context "show_search_notebook" do
    it "empty" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      get :show_search_notebook, params: { id: superheroes.id }

      expect(response).to have_http_status(200)
      expect(assigns(:search_results)).to be_empty
    end

    it "with content" do
      superheroes = SearchNotebook.new
      superheroes.title = "Superheroes"
      superheroes.save!

      dc_superheroes_query = SearchQuery.new
      dc_superheroes_query.query = "dc superheroes"
      dc_superheroes_query.total_hits_count = 0
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.hn_object_id = "4"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!
      wonder_woman = SearchResult.new
      wonder_woman.hn_login = "eat_veggies"
      wonder_woman.hn_object_id = "5"
      wonder_woman.url = "http://wonderwoman.com"
      wonder_woman.author_karma_points = 1140
      wonder_woman.tags = ["wonder_woman"]
      wonder_woman.search_query = dc_superheroes_query
      wonder_woman.save!

      Service.add_result_to_notebook(superheroes, [batman, wonder_woman])

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
      dc_superheroes_query.total_hits_count = 0
      dc_superheroes_query.save!

      batman = SearchResult.new
      batman.hn_login = "shaklee3"
      batman.hn_object_id = "6"
      batman.url = "http://batman.com"
      batman.author_karma_points = 1727
      batman.tags = ["batman"]
      batman.search_query = dc_superheroes_query
      batman.save!

      expect(superheroes.search_results.count).to eq 0

      post :add_search_result_to_search_notebook,
           params: { mode: "ajax", search_notebook_id: superheroes.id, search_result_id: batman.id }

      expect(superheroes.search_results.count).to eq 1
      search_result = superheroes.search_results.first
      expect(search_result).to eq batman

      # adding again same search result
      post :add_search_result_to_search_notebook,
           params: { mode: "ajax", search_notebook_id: superheroes.id, search_result_id: batman.id }

      # todo: consider disallowing adding same search result twice
      expect(superheroes.search_results.count).to eq 2
    end
  end

  context "statistics" do
    it "display" do
      dc_superheroes_query_1 = SearchQuery.new
      dc_superheroes_query_1.query = "dc superheroes"
      dc_superheroes_query_1.total_hits_count = 3
      dc_superheroes_query_1.save!
      dc_superheroes_query_2 = SearchQuery.new
      dc_superheroes_query_2.query = "dc superheroes"
      dc_superheroes_query_2.total_hits_count = 13
      dc_superheroes_query_2.save!
      dc_superheroes_query_3 = SearchQuery.new
      dc_superheroes_query_3.query = "dc superheroes"
      dc_superheroes_query_3.total_hits_count = 100
      dc_superheroes_query_3.created_at = 2.days.ago
      dc_superheroes_query_3.save!
      dc_superheroes_query_4 = SearchQuery.new
      dc_superheroes_query_4.query = "dc superheroes"
      dc_superheroes_query_4.total_hits_count = 200
      dc_superheroes_query_4.created_at = 8.days.ago
      dc_superheroes_query_4.save!
      marvel_superheroes_query = SearchQuery.new
      marvel_superheroes_query.query = "marvel superheroes"
      marvel_superheroes_query.total_hits_count = 300
      marvel_superheroes_query.save!
      cartoons_query = SearchQuery.new
      cartoons_query.query = "cartoons"
      cartoons_query.total_hits_count = 400
      cartoons_query.created_at = 8.days.ago
      cartoons_query.save!

      get :show_statistics

      items = assigns(:items)
      query_strings = items.map { |item| item[:query_string] }
      expect(query_strings).to match_array ["dc superheroes", "marvel superheroes", "cartoons"]
      dc_superheroes_item = items.find { |item| item[:query_string] == "dc superheroes" }
      expect(dc_superheroes_item[:last_day_total_hits_average]).to eq 8.0
      expect(dc_superheroes_item[:last_week_total_hits_average]).to eq 38.66
      marvel_superheroes_item = items.find { |item| item[:query_string] == "marvel superheroes" }
      expect(marvel_superheroes_item[:last_day_total_hits_average]).to eq 300.0
      expect(marvel_superheroes_item[:last_week_total_hits_average]).to eq 300.0
      cartoons_item = items.find { |item| item[:query_string] == "cartoons" }
      expect(cartoons_item[:last_day_total_hits_average]).to be_nil
      expect(cartoons_item[:last_week_total_hits_average]).to be_nil
    end
  end
end

describe "services" do
  it "clean search results old and not saved to notebook" do
    # todo
  end

  it "clean old search queries" do
    # todo
  end
end