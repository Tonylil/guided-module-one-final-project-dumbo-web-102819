class CreateRooms < ActiveRecord::Migration[5.2]
  def change
  	create_table :rooms do |t|
  		t.string :name
  		t.string :play_class
  		t.string :room_type
  		t.integer :max_hp
  		t.integer :hp
  		t.integer :attack
  		t.integer :defense
  		t.integer :heal
  		t.timestamps
  	end 
  end
end
