class AddContainerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :container_id, :string
  end
end
