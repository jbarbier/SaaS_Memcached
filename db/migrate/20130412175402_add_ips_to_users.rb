class AddIpsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :docker_ip, :string
    add_column :users, :secure_ip, :string
  end
end
