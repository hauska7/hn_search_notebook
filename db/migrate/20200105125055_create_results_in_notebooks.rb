class CreateResultsInNotebooks < ActiveRecord::Migration[5.2]
  def change
    create_table :results_in_notebooks do |t|
      t.timestamps null: false
    end

    add_reference :results_in_notebooks, :search_result, foreign_key: { to_table: :search_results }, null: false
    add_reference :results_in_notebooks, :search_notebook, foreign_key: { to_table: :search_notebooks }, null: false
  end
end
