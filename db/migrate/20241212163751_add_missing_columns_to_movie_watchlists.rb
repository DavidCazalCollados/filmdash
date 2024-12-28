class AddMissingColumnsToMovieWatchlists < ActiveRecord::Migration[7.1]
  def change
    StreamingLink.destroy_all
    MovieWatchlist.destroy_all

    add_column :movie_watchlists, :backdrop_path, :string
    add_column :movie_watchlists, :tmdb_id, :string
    rename_column :movie_watchlists, :description, :overview
    rename_column :movie_watchlists, :movie_poster, :poster_path
    change_column :movie_watchlists, :release_date, :string
    remove_column :movie_watchlists, :rating, :integer
    add_column :movie_watchlists, :vote_average, :string
    add_column :movie_watchlists, :runtime, :string
    add_column :movie_watchlists, :trailer_youtube_key, :string
  end
end
