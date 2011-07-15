class AddXpToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :xp, :integer
  end

  def self.down
    remove_column :players, :xp
  end
end
