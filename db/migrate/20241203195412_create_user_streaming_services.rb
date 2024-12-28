class CreateUserStreamingServices < ActiveRecord::Migration[7.1]
  def change
    create_table :user_streaming_services do |t|
      t.references :streaming_service, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
