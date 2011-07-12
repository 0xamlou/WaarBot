class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.integer :code
      t.string :name
      t.integer :cost
      t.integer :attack
      t.integer :defense

      t.timestamps
    end
  end

  def self.down
    drop_table :units
  end
end
