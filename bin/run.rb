require_relative '../config/environment'

puts "lol"
stuff = 'combat'

#r1 = Room.new({enemy_hp: 5, room_type: "combat"})


#p1 = Player.new({max_hp: 10, current_hp: 5})

game = Game.new()

game.dungeon_loop

prompt = TTY::Prompt.new
a1 = "Attack"
a2 = "Defend"
a3 = "Flee"
a4 = ["Attack", "Defend", "Flee"]
#testa = prompt.select("What do you do?", a4)

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
#luke = Swapi.get_person 1
#luke = JSON.parse(luke)

binding.pry