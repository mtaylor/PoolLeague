class AddPermissionsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notification, :boolean
    add_column :users, :session, :boolean
    add_column :users, :admin, :boolean
  end

  def self.down
    remove_column :users, :admin
    remove_column :users, :session
    remove_column :users, :notification
  end
end
