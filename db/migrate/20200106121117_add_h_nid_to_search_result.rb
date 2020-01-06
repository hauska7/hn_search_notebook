class AddHNidToSearchResult < ActiveRecord::Migration[5.2]
  def change
    add_column :search_results, :hn_object_id, :string, null: false
  end
end
