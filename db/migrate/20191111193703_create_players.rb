class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
  	create_table :players do |t|
  		t.integer :max_hp
  		t.integer :current_hp
  		t.integer :affinity
  		t.timestamps
  	end
  end
end
