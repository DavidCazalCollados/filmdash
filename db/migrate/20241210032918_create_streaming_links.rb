class CreateStreamingLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :streaming_links do |t|
      t.string :name
      t.string :link
      t.references :movie_watchlist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
