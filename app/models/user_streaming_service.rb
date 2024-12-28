class UserStreamingService < ApplicationRecord
  belongs_to :streaming_service
  belongs_to :user
end
