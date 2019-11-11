class CreateEncounters < ActiveRecord::Migration[5.2]
  def change
  	create_table :encounters do |t|
  		t.integer :player_id 
  		t.integer :room_id
  		t.integer :choice
  		t.timestamps
  	end 
  end
end
