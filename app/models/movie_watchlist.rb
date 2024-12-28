class MovieWatchlist < ApplicationRecord
  belongs_to :user
  has_many :streaming_links

  serialize :watch_providers, type: Array, coder: JSON
end
