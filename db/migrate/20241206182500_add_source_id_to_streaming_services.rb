class AddSourceIdToStreamingServices < ActiveRecord::Migration[7.1]
  def change
    add_column :streaming_services, :source_id, :integer
  end
end
