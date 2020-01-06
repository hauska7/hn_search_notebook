Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#root"

  get "show_search_notebook/:id", to: "main#show_search_notebook", as: "show_search_notebook"
  get "show_statistics", to: "main#show_statistics", as: "show_statistics"
  get "index_search_notebooks", to: "main#index_search_notebooks", as: "index_search_notebooks"
  get "search_hackernews", to: "main#search_hackernews", as: "search_hackernews"
  post "create_search_notebook", to: "main#create_search_notebook", as: "create_search_notebook"
  post "destroy_search_notebook/:id", to: "main#destroy_search_notebook", as: "destroy_search_notebook"
  post "remove_search_result_from_search_notebook/:search_result_id/:search_notebook_id", to: "main#remove_search_result_from_search_notebook", as: "remove_search_result_from_search_notebook"
  post "add_search_result_to_search_notebook/:search_result_id/:search_notebook_id", to: "main#add_search_result_to_search_notebook", as: "add_search_result_to_search_notebook"
end
