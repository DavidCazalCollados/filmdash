class AddStreamingLinksToMovieWatchlists < ActiveRecord::Migration[7.1]
  def change
    add_column :movie_watchlists, :watch_providers, :text, null: false, default: "[]"
  end
end
