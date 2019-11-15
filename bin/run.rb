require_relative '../config/environment'

game = Game.new()

game.dungeon_loop

# yugioh_url = "https://db.ygoprodeck.com/api/v5/cardinfo.php?type=trap+card"
# response = HTTParty.get(yugioh_url)
# trap_card_names = response.map do |r|
# 	r["name"]
# end

# puts trap_card_names


#puts ApiData.yugioh 


#puts Emotes.happy

#testMap = Map.new(4, 6)

#prompt = TTY::Prompt.new
#a1 = "Attack"
#a2 = "Defend"
#a3 = "Flee"
#a4 = ["Attack", "Defend", "Flee"]
#testa = prompt.select("What do you do?", a4)

#API TEST
#names = []
#for amt in 1..10
#	names << JSON.parse(Swapi.get_person(amt))["name"]
#end

#Names is gather from the API above this line.
#names = ["Luke Skywalker",
# "C-3PO",
# "R2-D2",
# "Darth Vader",
# "Leia Organa",
# "Owen Lars",
# "Beru Whitesun lars",
# "R5-D4",
# "Biggs Darklighter",
# "Obi-Wan Kenobi"]
#luke = Swapi.get_person 1
#luke = JSON.parse(luke)

# names = []
# 50.times do |t|
# 	if t != 16
# 		puts "T: #{t}"
# 		names << JSON.parse(Swapi.get_person(t+1))["name"]
# 	end
# end

#binding.pry