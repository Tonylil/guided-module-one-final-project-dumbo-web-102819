class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
  	create_table :players do |t|
  		t.string :name
  		t.string :play_class
  		t.integer :max_hp
  		t.integer :hp
  		t.integer :attack
  		t.integer :defense
  		t.integer :heal
  		t.timestamps
  	end
  end
end
