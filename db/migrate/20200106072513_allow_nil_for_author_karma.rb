class AllowNilForAuthorKarma < ActiveRecord::Migration[5.2]
  def change
    change_column :search_results, :author_karma_points, :integer, null: true
  end
end
