class AddMayAttackToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :may_attack, :integer
  end

  def self.down
    remove_column :players, :may_attack
  end
end
