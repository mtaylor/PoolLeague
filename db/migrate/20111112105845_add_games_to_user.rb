class AddGamesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :played, :integer, :default => 0
    add_column :users, :won, :integer, :default => 0
    add_column :users, :lost, :integer, :default => 0
    add_column :users, :draw, :integer, :default => 0
  end

  def self.down
    remove_column :users, :draw
    remove_column :users, :lost
    remove_column :users, :won
    remove_column :users, :played
  end
end
