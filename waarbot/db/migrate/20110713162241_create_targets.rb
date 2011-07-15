class CreateTargets < ActiveRecord::Migration
  def self.up
    create_table :targets do |t|
      t.integer :ingame_id
      t.string :name
      t.integer :xp
      t.integer :gold
      t.integer :state
      t.integer :population
      t.string :alliance

      t.timestamps
    end
  end

  def self.down
    drop_table :targets
  end
end
