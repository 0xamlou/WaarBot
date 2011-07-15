class RemoveHerosFromPlayer < ActiveRecord::Migration
  def self.up
    remove_column :players, :heros
  end

  def self.down
    add_column :players, :heros, :integer
  end
end
