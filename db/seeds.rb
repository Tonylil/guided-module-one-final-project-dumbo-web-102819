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
# names = ["Luke Skywalker",
#  "C-3PO",
#  "R2-D2",
#  "Darth Vader",
#  "Leia Organa",
#  "Owen Lars",
#  "Beru Whitesun lars",
#  "R5-D4",
#  "Biggs Darklighter",
#  "Obi-Wan Kenobi"]
 ########################. OLD Random Room Seeds ########################
 #room_types = ["trap", "friend", "combat"]

 # names.each do |name|
 # 	case room_types.sample
 # 	when "trap"
 # 		att = rand(3..5)
 # 		Room.create!({name: name, room_type: "trap", attack: att})
 # 	when "friend"
 # 		heal = rand(1..2)
 # 		Room.create!({name: name, room_type: "friend", heal: heal})
 # 	when "combat"
 # 		hp = rand(15..30)
 # 		att = rand(3..5)
 # 		defense = rand(1..2)
 # 		Room.create!({name: name, room_type: "combat", max_hp: hp, hp: hp, attack: att, defense: defense})
 # 	end
 # end

 names_combat = []

 ########   Creating Trap Rooms #######
#These are the names of the trap cards, from yugioh API
puts "Getting Trap Cards from Yugioh"

yugioh_url = "https://db.ygoprodeck.com/api/v5/cardinfo.php?type=trap+card"
response = HTTParty.get(yugioh_url)
trap_card_names = response.map do |r|
	r["name"]
end

puts "Finished with Yugioh API"

#Making trap rooms
10.times do
	att = rand(1..20)
	Room.create!({name: trap_card_names.sample, room_type: "trap", attack: att})
end


########   Creating Friend Rooms #######
#Getting 50 names for friendly rooms from Starwars API
#sw_people = JSON.parse(Swapi.get_all("people"))

names = []
sw_amt = 50
sw_amt.times do |t|
	#for some reason SW API DOESN"T HAVE a 17th person
	#16th person exist and 18th exist but not 17!!!
	if t != 16
		puts "Getting Star War Data: #{t+1}/#{sw_amt}"
		names << JSON.parse(Swapi.get_person(t+1))["name"]
	else
		puts "Skipping #{t+1} because for REASONS idk it doesn't exist in the Database."
	end	
end

#Making Friend Rooms
6.times do 
	heal = rand(1..30)
	Room.create!({name: names.sample, room_type: "friend", heal: heal})
end

########   Creating Combat Rooms #######
#Getting Data from the Pokemon API
puts "Stealing pokemons from pokecenter."
poke = PokeApi.get(pokemon: {limit: 151})
puts "We're blasting off again!"

#Getting Data from the Pokemon API
poke_name = poke.results.map do |p|
 	p.name
end

#Making combat rooms
10.times do
	hp = rand(30..100)
 	att = rand(1..50)
 	defense = rand(1..100)
 	Room.create!({name: poke_name.sample, room_type: "combat", max_hp: hp, hp: hp, attack: att, defense: defense})
end

############ Forcefully create a player ################
 p1 = Player.create
 p1.name = "Dominic"
 p1.hp = 100
 p1.max_hp = 100
 p1.attack = 30
 p1.defense = 15
 p1.save  

 p2 = Player.create
 p2.name = "Fanzhong"
 p2.hp = 100
 p2.max_hp = 100
 p2.attack = 15
 p2.defense = 30
 p2.save  
