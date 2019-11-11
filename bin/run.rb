require_relative '../config/environment'

puts "lol"
stuff = 'combat'

r1 = Room.new({number: 18, enemy_hp: 5, room_type: "combat"})


p1 = Player.new({affinity: 12, max_hp: 10, current_hp: 5})

game = Game.new(p1)

#game.dungeon_loop

prompt = TTY::Prompt.new
a1 = "Attack"
a2 = "Defend"
a3 = "Flee"
a4 = ["Attack", "Defend", "Flee"]
testa = prompt.select("What do you do?", a4)

binding.pry