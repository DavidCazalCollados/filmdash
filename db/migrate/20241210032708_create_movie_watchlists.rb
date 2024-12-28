class CreateMovieWatchlists < ActiveRecord::Migration[7.1]
  def change
    create_table :movie_watchlists do |t|
      t.string :title
      t.string :description
      t.date :release_date
      t.string :movie_poster
      t.integer :rating
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
