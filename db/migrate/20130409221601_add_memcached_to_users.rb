class AddMemcachedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :memcached, :string
  end
end
