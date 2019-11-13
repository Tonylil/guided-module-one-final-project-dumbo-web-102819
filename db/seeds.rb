require_relative '../config/environment'
Room.destroy_all
Player.destroy_all
Encounter.destroy_all
#API TEST
#names = []
#for amt in 1..10
#	names << JSON.parse(Swapi.get_person(amt))["name"]
#end

#Names is gather from the API above this line.
names = ["Luke Skywalker",
 "C-3PO",
 "R2-D2",
 "Darth Vader",
 "Leia Organa",
 "Owen Lars",
 "Beru Whitesun lars",
 "R5-D4",
 "Biggs Darklighter",
 "Obi-Wan Kenobi"]

 room_types = ["trap", "friend", "combat"]

 names.each do |name|
 	case room_types.sample
 	when "trap"
 		att = rand(3..5)
 		Room.create!({name: name, room_type: "trap", attack: att})
 	when "friend"
 		heal = rand(1..2)
 		Room.create!({name: name, room_type: "friend", heal: heal})
 	when "combat"
 		hp = rand(15..30)
 		att = rand(3..5)
 		defense = rand(1..2)
 		Room.create!({name: name, room_type: "combat", max_hp: hp, hp: hp, attack: att, defense: defense})
 	end
 end

 names_combat = []
 names_friend = []
 names_trap = []


 p1 = Player.create
 p1.name = "Dominic"
 p1.hp = 50
 p1.max_hp = 50
 p1.attack = 15
 p1.defense = 10
 p1.save  
