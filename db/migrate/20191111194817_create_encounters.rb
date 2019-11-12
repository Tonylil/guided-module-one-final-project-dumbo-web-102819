class CreateEncounters < ActiveRecord::Migration[5.2]
  def change
  	create_table :encounters do |t|
  		t.integer :player_id 
  		t.integer :room_id
  		t.integer :result
  		t.integer :hp_change
  		t.timestamps
  	end 
  end
end
