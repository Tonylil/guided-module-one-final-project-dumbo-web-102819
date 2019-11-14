class Game 


	def initialize()
		@player = Player.new({max_hp: 10, hp: 5, attack: 3, defense: 1})
		@prompt = TTY::Prompt.new
		
		@choice_string = {
		start: "Start Game",
		new_game: "New Game",
		continue: "Continue",
		highscore: "Highscore",
		exit: "Exit",
		n: "North",
		e: "East",
		s: "South",
		w: "West",
		attack: "Attack",
		defend: "Defend",
		run: "Flee",
		heal: "Heal",
		start_new_game: "Start New Game",
		continue_from_savefile: "Continue from Savefile",
		max_hp: "Max HP",
		hp: "HP",
		most_kills: "Most Kills",
		most_heals: "Most Heals",
		most_traps: "Most Traps",
		exit_command: "Exit", 
		defense: "Defense"}

	end

	def dungeon_loop
		exit_game = false
		while (!exit_game)
			case main_screen
			when @choice_string[:start]
				start_or_continue = selection("What would you like to do?", [@choice_string[:start_new_game], @choice_string[:continue_from_savefile]])

				@game_map = Map.new(5, 8)
					case start_or_continue 
					when @choice_string[:start_new_game]
						#New Game, which creates character
						create_characters
						dungeon
					when @choice_string[:continue_from_savefile]

						#: Continue, load from DB and choose one file to continue playing
						if continue_game
							dungeon
						end
					end
			when @choice_string[:highscore]
				puts "Checking Highscore"
				update_room_info
				highscore_method
			when @choice_string[:exit]
				puts "Thank You for Playing, Have a Nice Day."
				@prompt.keypress("Game will close automatically in :countdown ...", timeout: 10)
				exit_game = true
			else
				puts "Error, unknown choice"
			end

		end
		#dungeon
	end

	def main_screen
		clear_screen
		selection("Welcome to Dummy Dungeon v0.01  (　＾∇＾)", [@choice_string[:start], @choice_string[:highscore], @choice_string[:exit]])
	end

	def create_characters
		namesies = @prompt.ask("What is your name?") do |q|
			q.required true
			q.validate /\A\w+\Z/
			q.modify   :capitalize
		  end
		#Ask for name, 
		stats_ok = "Whatever"
		until stats_ok == "Happy"
			new_hash = create_stats 
			stats_ok = selection("Your stats are ATK #{new_hash[:attack]}, DEF #{new_hash[:defense]} and HP #{new_hash[:hp]}. Are you happy or would you like to reroll", ["Happy", "Reroll"])
			#Rnadom stats, and let user reroll
		end 
		new_hash[:name] = namesies

		#Create the character (create is combined new + Save)
		puts "(ง •̀_•́)ง"
		puts "Great! #{namesies}, let's start your journey."
		press_to_continue

		#Enter the game with the character, aka return the character
		@player = Player.create(new_hash)
	end

	def show_all_savefiles
		all_players = Player.all.map do |instance|
			instance.name
		end
		savefile_name = ""
		in_the_game = false
		while (!in_the_game)
			#Making sure if the player chooses a name that exist
			until all_players.include?(savefile_name)
				puts "Here are all of the savefiles"
				Player.all.each do |instance|
					puts "Savefile #{instance.id}. Name: #{instance.name}"
				end 
				savefile_name = @prompt.ask("What's your name?") do |q|
					q.required true
					q.validate /\A\w+\Z/
					q.modify   :capitalize
				end	

				if (!all_players.include?(savefile_name))
					clear_screen
					puts "Error Player doesn't exist, please enter again: "
				end

			end
			continue_player = Player.all.find_by("name": savefile_name)
			show_savefile(continue_player)
			save_file_yes_or_no = selection("Is this your savefile?", ["Yes", "No, who this?"])

			if save_file_yes_or_no == "Yes"
				in_the_game = true
			else
				savefile_name = ""
			end
			clear_screen
		end
		@player = continue_player
		"Yes"
	end

	def continue_game
		until show_all_savefiles == "Yes"
			show_all_savefiles
		end
		crud_savefile = selection("OK #{@player.name}, what do you want to do?", ["Continue from here", "Delete this savefile", "Exit to Main Menu"])
		case crud_savefile 
		when "Continue from here"
			return true
		when "Delete this savefile"
			encounters_to_axe = Encounter.all.select do |instance|
				instance.player_id == @player.id
			end 
			encounters_to_axe.each do |instance|
				instance.destroy
			end 
			@player.destroy
			puts "You have deleted this savefile and all encounters related to it."
			press_to_continue
		end
		return false
	end

	def check_leaderboards 
		playerz = Player.all 
		encounterz = Encounter.all
			case selection("Which category?", [@choice_string[:attack], @choice_string[:defense], @choice_string[:max_hp], @choice_string[:hp], @choice_string[:most_kills], @choice_string[:most_heals], @choice_string[:most_traps], @choice_string[:exit_command]])
			when @choice_string[:attack]
				sorted = playerz.sort_by { |instance| -instance.attack }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.attack} ATTACK "
				end 
				check_leaderboards
			when @choice_string[:defense]
				sorted = playerz.sort_by { |instance| -instance.defense }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.defense} DEFENSE"
				end
				check_leaderboards
			when @choice_string[:max_hp]
				sorted = playerz.sort_by { |instance| -instance.max_hp }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.max_hp} MAX HP"
				end 
				check_leaderboards
			when @choice_string[:hp]
				sorted = playerz.sort_by { |instance| -instance.hp }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.hp} HP"
				end 
				check_leaderboards
			when @choice_string[:most_kills]
				new_array = Array.new
				#to use later
				new_hash = Hash.new
				#to store encounter count per player
				combat_rooms = Room.all.select do |room|
					room.room_type == "combat"
				end
				#filter out only combat rooms
				combat_ids = combat_rooms.map do |combat_room|
					combat_room.id 
				end 
				#map to just ids
				combat_encounters = Encounter.all.select do |encounter|
					combat_ids.include?(encounter.room_id)
				end 
				#select all encounters with room_id that are combat types
				combat_encounters.each do |encounter|
					if new_hash[encounter.player_id]
						new_hash[encounter.player_id] += 1
					else 
						new_hash[encounter.player_id] = 1
					end 
					#in the counting hash add counts per player_id
				end 
				new_hash.each do |key, value|
					#going through the counting hash and selecting the applicable players
					current_player_instance_array = Player.all.select do |instance|
						instance.id == key
					end
					new_array << "#{value} Enemies killed by #{current_player_instance_array[0].name}"
					# shoveling into an array, the number of encounters w/player name
				end 
				sorted_array = new_array.sort.reverse
				#sort in reverse the array so that 9 is before 8 etc like in a ranking high-to-low
				sorted_array.each do |item|
					puts item 
					#puts all in order from high to low the top players for this encounter type
				end 
				check_leaderboards
			when @choice_string[:most_heals]
				new_array = Array.new
				new_hash = Hash.new
				heal_rooms = Room.all.select do |room|
					room.room_type == "friend"
				end
				friend_ids = heal_rooms.map do |heal_room|
					heal_room.id 
				end 
				heal_encounters = Encounter.all.select do |encounter|
					friend_ids.include?(encounter.room_id)
				end 
				heal_encounters.each do |encounter|
					if new_hash[encounter.player_id]
						new_hash[encounter.player_id] += 1
					else
						new_hash[encounter.player_id] = 1
					end 
				end 
				new_hash.sort_by { |object, value| value }
				new_hash.each do |key, value|
					current_player_instance_array = Player.all.select do |instance|
						instance.id == key
					end 
					new_array << "#{value} Friends encountered by #{current_player_instance_array[0].name}"
				end 
				sorted_array = new_array.sort.reverse
				sorted_array.each do |item|
					puts item 
				end 
				check_leaderboards
			when @choice_string[:most_traps]
				new_array = Array.new
				new_hash = Hash.new
				trap_rooms = Room.all.select do |room|
					room.room_type == "trap"
				end
				trap_ids = trap_rooms.map do |trap_room|
					trap_room.id 
				end 
				trap_encounters = Encounter.all.select do |encounter|
					trap_ids.include?(encounter.room_id)
				end 
				trap_encounters.each do |encounter|
					if new_hash[encounter.player_id]
						new_hash[encounter.player_id] += 1
					else
						new_hash[encounter.player_id] = 1
					end 
				end 
				new_hash.sort_by { |object, value| value }
				new_hash.each do |key, value|
					current_player_instance_array = Player.all.select do |instance|
						instance.id == key
					end 
					new_array << "#{value} Traps encountered by #{current_player_instance_array[0].name}"
				end 
				sorted_array = new_array.sort.reverse
				sorted_array.each do |item|
					puts item 
				end 
				check_leaderboards
			when @choice_string[:exit_command]
				return
			end 
	end
	

	def highscore_method
		case selection("Hi, what would you like to do?", ["Check Leaderboard", "Check Stats", "Check Killstory"])
		when "Check Leaderboard"
			check_leaderboards 
		when "Check Stats"
			check_stats
		when "Check Killstory"
			check_killstory 
		end 
	end
	def check_stats 
		check_stats_choice = selection("What stat would you like to see?", ["Players", "Enemies", "Friends", "Traps", "Exit"])
		case check_stats_choice
		when "Players"
			names = Player.all.map { |player| player.name }
			choice_name = selection("Which player's details would you like to see?", names)
			temp_var = Player.all.select { |player| player.name == choice_name }
			puts "#{temp_var[0].name}"
			puts "#{temp_var[0].attack} ATTACK"
			puts "#{temp_var[0].defense} DEFENSE"
			puts "#{temp_var[0].hp} HP"
			puts "#{temp_var[0].max_hp} MAX_HP"
			puts "#{temp_var[0].created_at} CREATED AT"
			puts "#{temp_var[0].updated_at} LAST PLAYED"
			press_to_continue
			check_stats  
		when "Enemies"
			roomz = Room.all.select { |room| room.room_type == "combat"}
			names = roomz.map { |room| room.name }
			choice_name = selection("Which Enemy's details would you like to see?", names)
			temp_var = Room.all.select { |player| player.name == choice_name }
			puts "#{temp_var[0].name}"
			puts "#{temp_var[0].attack} ATTACK"
			puts "#{temp_var[0].defense} DEFENSE"
			puts "#{temp_var[0].hp} HP"
			puts "#{temp_var[0].max_hp} MAX_HP"
			press_to_continue
			check_stats  
		when "Friends"
			roomz = Room.all.select { |room| room.room_type == "friend"}
			names = roomz.map { |room| room.name }
			choice_name = selection("Which Friendly's details would you like to see?", names)
			temp_var = Room.all.select { |player| player.name == choice_name }
			puts "#{temp_var[0].name}"
			puts "#{temp_var[0].heal} HEALING FACTOR"
			press_to_continue
			check_stats  
		when "Traps"
			roomz = Room.all.select { |room| room.room_type == "trap"}
			names = roomz.map { |room| room.name }
			choice_name = selection("Which Trap's details would you like to see?", names)
			temp_var = Room.all.select { |player| player.name == choice_name }
			puts "#{temp_var[0].name}"
			puts "#{temp_var[0].attack} DAMAGE"
			press_to_continue
			check_stats 
		when "Exit"
			return
		end 
	end 
	def check_killstory 
		names = Player.all.map { |player| player.name }
		choice_name = selection("Which player's Kill History would you like to see?", names)
		temp_var = Player.all.select { |player| player.name == choice_name }
		specific_encounters = Encounter.all.select do |instance|
			instance.player_id == temp_var[0].id
		end 
		sorted_enc = specific_encounters.sort_by { |object| object.created_at}
		sorted_enc.each do |instance|
			temp_yo = Room.all.select { |room| room.id == instance.room_id }
			### assigns the room to temp_yo.... switching from Encounter to Room dataset
			
			if @combat_ids.include?(instance.room_id)
				case instance.result
				when 0
					# _____ killed player
					puts "#{temp_yo[0].name} killed #{temp_var[0].name} "
				when 1
					# player killed _____ 
					puts "#{temp_var[0].name} killed #{temp_yo[0].name}"
				when 2
					# player ran from _____
					puts "#{temp_var[0].name} ran like a coward from #{temp_yo[0].name}"
				end 
			elsif @friend_ids.include?(instance.room_id)
				case instance.result
				when 0
					# refused help
					puts "#{temp_var[0].name} refused sweet sensual healing from #{temp_yo[0].name}"
				when 1
					# accepted help
					puts "#{temp_var[0].name} accepted sweet sensual healing from #{temp_yo[0].name}"
				end 
			elsif @trap_ids.include?(instance.room_id)
				## trap always hits 
				puts "#{temp_var[0].name} took nefarious damage from #{temp_yo[0].name}"
			end 
		end 
		press_to_continue
	end


	################## Core Gameplay Functions ##############
	#Move a direction, return the direction
	def dungeon
		@save_quit = false
		while (still_alive? && !victory? && !@save_quit)
			clear_screen
			@game_map.show_map
			moving

			if (!@save_quit)
				new_room = Room.all.sample
				case new_room.room_type
				when "combat"
					battle(new_room)
				when "friend"
					friend(new_room)
				when "trap"
					obsticle(new_room)
				end
			end
		end

		#If you died
		if (!still_alive?)
			puts "You have died."
			press_to_continue
		end
	end

	def moving
		valid_input = false

		while(!valid_input)
			puts "#{@player.name}  HP: #{@player.hp}/#{@player.max_hp} Att: #{@player.attack} Def: #{@player.defense}"
			direction = selection("Which direction would you like to choose?", [@choice_string[:n], @choice_string[:e], @choice_string[:s], @choice_string[:w], "Quit"])
			clear_screen
			#Making sure the choice is valid
			case direction 
			when @choice_string[:n], @choice_string[:e], @choice_string[:s], @choice_string[:w]
				#now check if we can move in the direction
				if @game_map.move(direction)
					valid_input = true
				else
					@game_map.show_map
					puts "You cannot move in that direction."
				end
			when "Quit"
				@player.save
				@save_quit = true
				valid_input = true 
			else
				#This shouldn't be needed
				puts "Your Input is invalid, please enter again."
			end 
		end
	end

	def friend(friend)
		#Get heal based on room healing varible
		clear_screen

		puts "(>◕ᴗ◕)> ~ <3"
		puts "You found your friend #{friend.name}. They offer to help you."
		accept_help = selection("Will you accept their help?", ["Yes", "No"])
		if accept_help == "Yes"
			puts "You have been healed for #{friend.heal} HP."
			@player.get_heal(friend.heal)

			press_to_continue
			Encounter.create({player_id: @player.id, room_id: friend.id, result: 1})
			#### room_id == friend & result == 1 means HEALED
		else
			puts "You rejected #{friend.name}'s help, and told them to get a life."

			press_to_continue
			Encounter.create({player_id: @player.id, room_id: friend.id, result: 0})
			#### room_id == friend & result == 0 means REFUSED HEAL
		end
	end

	def obsticle(obsticle)
		#Traps, takes damage
		clear_screen

		puts "༼⍨༽ You have triggered my trap card \"#{obsticle.name}\"."
		puts "You take #{obsticle.attack} damage, it's super effective!"
		@player.take_dmg(obsticle.attack)
		press_to_continue

		#Save conflict 
		Encounter.create({player_id: @player.id, room_id: obsticle.id, result: 0})
	end

	def battle(enemy)
		clear_screen

		puts "A wild #{enemy.name} has appeared."
		puts "♪ ~ Insert Your Pokemon Theme Here ~ ♪"
		while (enemy.hp > 0 && @player.hp > 0) 

			valid_input = false
			while(!valid_input)
				choice = selection("Your HP: #{@player.hp}. Enemy HP: #{enemy.hp}.", ["Attack", "Defend", "Run"])
				valid_input = true
				clear_screen

				enemy_choice = ["Attack", "Defend", "AFK"].sample

				case choice
				when "Attack"
					case enemy_choice
					when "Attack"
						puts player_attack_quote(@player.attack, enemy)
						puts enemy_attack_quote(enemy, @player)

						enemy.take_dmg(@player.attack)
						@player.take_dmg(enemy.attack)
					when "Defend"
						puts anyone_defend_quote(enemy)

						player_attack_defended(@player, enemy)
					when "AFK"
						puts player_attack_quote(@player.attack, enemy)
						puts enemy_afk_quote(enemy)

						enemy.take_dmg(@player.attack)
					else
						puts "¯\\_( ͡° ͜ʖ ͡°)_/¯"
						puts "Lol games broken, you shouldn't be here"
					end
				when "Defend"
					case enemy_choice
					when "Attack"
						puts anyone_defend_quote(@player)

						enemy_attack_defended(enemy, @player)
					when "Defend"
						puts anyone_defend_quote(@player)
						puts anyone_defend_quote(enemy)

						puts "\nAn hour passes by and nothing happens..."
					when "AFK"
						puts anyone_defend_quote(@player)
						puts "#{enemy.name} looks at you, takes out a bag of popcorn and start eating it."
					else
						puts "¯\\_( ͡° ͜ʖ ͡°)_/¯"
						puts "Lol games broken, you shouldn't be here"
					end

				when "Run"
					@player.take_dmg(enemy.attack)
				  	puts "#{enemy.name} hits you as you try to run."
				 	puts "{\__/}"
				 	puts "(●_●)"
				 	puts "( >🌮"
				 	puts "You have fled"
				 	press_to_continue
				 	return
				else
					puts "¯\\_( ͡° ͜ʖ ͡°)_/¯"
					puts "You somehow fked up the choice and breaked the game."
				end
				press_to_continue
			end 
		end
		
		result = -1
		if @player.hp <= 0

			result = -0
			### result = 0 is DEAD
		elsif enemy.hp <= 0 
			result = 1
			### result = 1 ALIVE 
		else 
			result = 2
			### result = 2 FLED
		end 
		#Save this encounter
		Encounter.create({player_id: @player.id, room_id: enemy.id, result: result})
	end

	def still_alive?
		@player.hp > 0 ? true : false
	end

	def victory?
		#Return True if we beat the game winning condiction

		#Return false if we haven't beat the game yet
		false
	end

	def encounter(room, result)
		#TODO: Create the result, and save it as a new encounter
	end

	################ HIGHScore Related Functions. ###################
	def highscore
		array_of_choices = Player.all.map do |player|
			player.name
		end
		array_of_choices << "Exit"

		choice = selection("Choose whose date you want to see.", array_of_choices)

		if (choice != "Exit")
			show_savefile(Player.all.find_by(name: choice))
			press_to_continue
		end
		puts array_of_choices
	end

	################ Helper Functions. ###################
	def clear_screen
		system("clear")
	end

	def wait(time)
		#TODO, freeze the screen for x amt of time
	end

	def press_to_continue
		@prompt.keypress("Press space or enter to continue", keys: [:space, :return])
	end

	def timeout
		@prompt.keypress("Press any key to continue, resumes automatically in :countdown ...", timeout: 10)
	end

	#Question is a string, choices is an array of strings
	#Returns the choice that u made
	def selection(question, choices)
		@prompt.select(question, choices)
	end

	def create_stats
		new_hash = {}
		new_hash[:attack] = rand(30..60)
		new_hash[:defense] = rand(1..30)
		new_hash[:max_hp] = rand(100..300)
		new_hash[:hp] = new_hash[:max_hp]
		new_hash
	end

	def show_savefile(player_instance)
		puts "Name: #{player_instance.name}"
		puts "Attack: #{player_instance.attack}"
		puts "Defense: #{player_instance.defense}"
		puts "Max HP: #{player_instance.max_hp}"
		puts "Current HP: #{player_instance.hp}"
		puts "Last Played on #{player_instance.updated_at}"
	end 

	def player_attack_quote(dmg, enemy)
		quotes = ["You wanted to attack #{enemy.name}, except he ran and dodged your attack.\nThen he slipped and hurt himself for #{dmg} HP.",
			"You told #{enemy.name} to look behind him, then you attacked while he wasn't looking. \n#{enemy.name} took #{dmg} damage.",
			"You tried to attack but tripped over your own feet. Only to get up and this time trip over nothing.\n#{enemy.name} took pity on you and let you hit him for #{dmg} damage."]
		quotes.sample
	end

	def player_attack_defended(player, enemy)
		dmg_dealt = player.attack - enemy.defense
		if dmg_dealt < 1
			dmg_dealt = 1
		end

		#TODO: Future think of funny quotes
		puts player_attack_quote(dmg_dealt,enemy)

		enemy.take_dmg(dmg_dealt)
	end

	def enemy_attack_quote(enemy, player)
		quotes = ["#{enemy.name} starts to charge at you. You go down on your knee and beg for him not to attack you. \n#{enemy.name} ignores your attempt and hits you for #{enemy.attack} damage.",
			"You fight hard against #{enemy.name}, however #{enemy.name} was better overall.\nYou lost #{player.hp} HP.",
			"After an intense battle between #{player.name} and #{enemy.name}. #{player.name} got distracted by a flower on the side. \n#{enemy.name} took this chance and hits #{player.name} for #{enemy.attack} damage."]
		quotes.sample
	end

	def enemy_afk_quote(enemy)
		quotes = ["#{enemy.name} slowly looks up at the sky, doubting his own existence.",
			"#{enemy.name} open his mouth and wants to say something... \n30 minute passes and he just closes his mouth and act like nothing happened.",
			"#{enemy.name} stares at you intensely."]
		quotes.sample
	end
	def enemy_attack_defended(enemy, player)
		dmg_dealt = enemy.attack - player.defense
		if dmg_dealt < 1
			dmg_dealt = 1
		end

		puts "You somehow still get hit for #{dmg_dealt} damage."

		player.take_dmg(dmg_dealt)
	end


	def anyone_defend_quote(person)
		quotes = ["#{person.name} picks up a rock on the ground, hoping to defend himself with it.",
			"#{person.name} brace himself for the next attack.",
			"#{person.name} roars, then shoves his own head into the ground. \nIf you can't see the enemy, they don't exist right?"]
		quotes.sample
	end

	def update_room_info
		@combat_rooms = Room.all.select { |instance| instance.room_type == "combat" }
		@combat_ids = @combat_rooms.map { |instance| instance.id }
		@friend_rooms = Room.all.select { |instance| instance.room_type == "friend" }
		@friend_ids = @friend_rooms.map { |instance| instance.id }
		@trap_rooms = Room.all.select { |instance| instance.room_type == "trap" }
		@trap_ids = @trap_rooms.map { |instance| instance.id }
	end 
end