class AllowNullForUrl < ActiveRecord::Migration[5.2]
  def change
    change_column :search_results, :url, :string, null: true
  end
end
