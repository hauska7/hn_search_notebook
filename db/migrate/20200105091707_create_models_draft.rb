class CreateModelsDraft < ActiveRecord::Migration[5.2]
  def change
    create_table :search_notebooks do |t|
      t.string :title, null: false

      t.timestamps null: false
    end

    create_table :search_queries do |t|
      t.string :query, null: false
      t.integer :total_hits_count, null: false

      t.timestamps null: false
    end

    create_table :search_results do |t|
      t.string :hn_login, null: false
      t.string :url, null: false
      t.integer :author_karma_points, null: false
      t.string :tags, array: true, null: false

      t.timestamps null: false
    end

    add_reference :search_results, :search_query, foreign_key: { to_table: :search_queries }, null: false
  end
end
