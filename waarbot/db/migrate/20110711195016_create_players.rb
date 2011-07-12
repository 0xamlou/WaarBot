class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.string :name
      t.string :password
      t.integer :gold
      t.integer :mine
      t.integer :soldiers
      t.integer :knights
      t.integer :archers
      t.integer :heros
      t.string :alliance_name
      t.integer :alliance_id
      t.integer :state

      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
