class AddColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :vpn, :boolean, default: false, null: false
    add_column :users, :country, :string
  end
end
