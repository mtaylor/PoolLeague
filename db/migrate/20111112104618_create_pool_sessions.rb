class CreatePoolSessions < ActiveRecord::Migration
  def self.up
    create_table :pool_sessions do |t|
      t.integer :id
      t.integer :player1, :null => false
      t.integer :player2, :null => false
      t.integer :player1_score, :default => 0
      t.integer :player2_score, :default => 0
      t.integer :draws, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :pool_sessions
  end
end
