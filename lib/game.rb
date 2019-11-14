class Game 

	def initialize()
		@player = Player.new({max_hp: 10, hp: 5, attack: 3, defense: 1})
		@prompt = TTY::Prompt.new
		@combat_rooms = Room.all.select { |instance| instance.room_type == "combat" }
		@combat_ids = @combat_rooms.map { |instance| instance.id }
		@friend_rooms = Room.all.select { |instance| instance.room_type == "friend" }
		@friend_ids = @friend_rooms.map { |instance| instance.id }
		@trap_rooms = Room.all.select { |instance| instance.room_type == "trap" }
		@trap_ids = @trap_rooms.map { |instance| instance.id }

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

		#making a new map
		@game_map = Map.new(5, 8)
	end

	def dungeon_loop
		exit_game = false
		while (!exit_game)
			case main_screen
			when @choice_string[:start]
				start_or_continue = selection("What would you like to do?", [@choice_string[:start_new_game], @choice_string[:continue_from_savefile]])
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
				highscore_method
			when @choice_string[:exit]
				puts "Thank You for Playing, Have a Nice Day."
				press_to_continue
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
		puts "Great! #{namesies}, let's start your journey."

		#Enter the game with the character, aka return the character
		@player = Player.create(new_hash)
	end

	def show_all_savefiles
		all_players = Player.all.map do |instance|
			instance.name
		end
		savefile_name = ""
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
		end

		continue_player = Player.all.find_by("name": savefile_name)
		show_savefile(continue_player)
		save_file_yes_or_no = selection("Is this your savefile?", ["Yes", "No, who this?"])
		until save_file_yes_or_no == "Yes" 
			puts "Here are all of the savefiles"
			Player.all.each do |instance|
				puts "Savefile #{instance.id}. Name: #{instance.name}"
			end 
			savefile_name = @prompt.ask("What's your name?") do |q|
				q.required true
				q.validate /\A\w+\Z/
				q.modify   :capitalize
		    end
			continue_player = Player.all.find_by("name": savefile_name)
			show_savefile(continue_player)
			save_file_yes_or_no = selection("Is this your savefile?", ["Yes", "No, who this?"])
		end
		@player = continue_player
		"Yes"
	end

	# def ask_name_and_search_savefile
	# 	savefile_name = @prompt.ask("What is the name on file?") do |q|
	# 		q.required true
	# 		q.validate /\A\w+\Z/
	# 		q.modify   :capitalize
	# 	end
	
	# 		continue_player = Player.all.find_by("name": savefile_name)
		 
	# 	show_savefile(continue_player)
	# 	save_file_yes_or_no = selection("Is this your savefile?", ["Yes", "No, who this?"])
	# 	if save_file_yes_or_no == "Yes"
	# 		@player = player_instance
	# 		"Yes"
	# 	else 
	# 		"No, who this?"
	# 	end 
	# end 

	def continue_game
		until show_all_savefiles == "Yes"
			show_all_savefiles
		end
		crud_savefile = selection("OK #{@player.name}, what do you want to do?", ["Continue from here", "Delete this savefile", "Exit to Main Menu"])
		case crud_savefile 
		when "Continue from here"
			return true
		when "Delete this savefile"
			@player.destroy
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
				main_screen
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
		check_stats_choice = selection("What stat would you like to see?", ["Players", "Enemies", "Friends", "Traps"])
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
		while (still_alive? && !victory?)
			clear_screen
			@game_map.show_map
			moving

			hp = rand(15..30)
 			att = rand(3..5)
 			defense = rand(1..2)
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

		#If you died
		if (!still_alive?)
			puts "You have died."
		end
	end

	def moving
		valid_input = false

		while(!valid_input)
			direction = selection("Which direction would you like to choose?", [@choice_string[:n], @choice_string[:e], @choice_string[:s], @choice_string[:w]])
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
				# puts "Your HP: #{@player.current_hp}. Enemy HP: #{enemy.enemy_hp}" 
				# puts "What do you want to do?"
				# puts "1) Attack"
				# puts "2) Defend"
				# puts "3) Run"

				#Player input
				# choice = gets.chomp.to_i
				valid_input = true
				clear_screen
				if choice == "Attack"
					#Code to attack
					#call room #take_dmg
					enemy.take_dmg(@player.attack)
					puts "(　-_･)σ - - - - - - - - ･"
					puts "(∩｀-´)⊃━☆ﾟ.*･｡ﾟ"
					puts "You damaged the enemy for #{@player.attack} amount."
				elsif choice == "Defend"
					#Code to lower dmg taken
					@player.take_dmg(-1)
					puts "ヽ(ﾟДﾟ)ﾉ"
					puts "You defended"
				elsif choice == "Run"
					#Code to run
					@player.take_dmg(enemy.attack)
					puts "#{enemy.name} hits you as you try to run."
					puts "{\__/}"
					puts "(●_●)"
					puts "( >🌮"
					puts "You have fled"
					return 
				else
					puts "¯\_( ͡° ͜ʖ ͡°)_/¯"
					puts "Your Input is invalid, please enter again."
					valid_input = false
				end

				#enemy AI
				enemy_choice = rand(1..2)
				if enemy_choice == 1
					#enemy attacks
					@player.take_dmg(enemy.attack)
					puts "#{enemy.name}  attacked you for #{enemy.attack} damage"
					wait(1)

				elsif enemy_choice == 2
					#enemy looks at u
					puts "#{enemy.name} looks up at the sky."
					wait(1)
				end
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

	#UNUSED FUNCTION
	def timeout
		@prompt.keypress("Press any key to continue, resumes automatically in :countdown ...", timeout: 5)
	end

	#Question is a string, choices is an array of strings
	#Returns the choice that u made
	def selection(question, choices)
		@prompt.select(question, choices)
	end

	def create_stats
		new_hash = {}
		new_hash[:attack] = rand(1..10)
		new_hash[:defense] = rand(1..10)
		new_hash[:max_hp] = rand(15..30)
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
end