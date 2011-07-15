class AddHeroesToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :heroes, :integer
  end

  def self.down
    remove_column :players, :heroes
  end
end
