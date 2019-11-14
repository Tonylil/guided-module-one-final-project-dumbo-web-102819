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
		heal: "Heal"}
	end

	def dungeon_loop
		exit_game = false
		while (!exit_game)
			case main_screen
			when @choice_string[:start]
				start_or_continue = selection("What would you like to do?", ["Start New Game", "Continue from Savefile"])
				@game_map = Map.new(5, 8)
					case start_or_continue 
					when "Start New Game"
						#New Game, which creates character
						create_characters
						dungeon
					when "Continue from Savefile"

						#: Continue, load from DB and choose one file to continue playing
						if continue_game
							dungeon
						end
					end
			when @choice_string[:highscore]
				puts "Checking Highscore"
				highscore
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
		puts @choice_string[:start]
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
		leaderboard_question = selection("Which category?", ["Attack", "Defense", "Max HP", "HP", "Most Kills", "Most Heals", "Most Traps", "Exit"])
			case leaderboard_question
			when "Attack"
				sorted = playerz.sort_by { |instance| -instance.attack }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.attack} ATTACK "
				end 
				check_leaderboards
			when "Defense"
				sorted = playerz.sort_by { |instance| -instance.defense }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.defense} DEFENSE"
				end
				check_leaderboards
			when "Max HP"
				sorted = playerz.sort_by { |instance| -instance.max_hp }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.max_hp} MAX HP"
				end 
				check_leaderboards
			when "HP"
				sorted = playerz.sort_by { |instance| -instance.hp }
				sorted.each do |instance|
					puts "#{instance.name} : #{instance.hp} HP"
				end 
				check_leaderboards
			when "Most Kills"
				combat_rooms = Room.all.select do |room|
					room.room_type == "combat"
				end
				new_hash = {}
				combat_rooms.each do |encounter|
					if new_hash[encounter.player_id]
						new_hash[encounter.player_id] += 1
					else 
						new_hash[encounter.player_id] = 1
					end 
				end 
				new_hash.sort_by { |object, value| value }
				new_hash.each do |key, value|
					
					puts "Player : #{playerz[key].name} has killed #{value} enemies"
				end 
				check_leaderboards
			when "Most Heals"
				heal_rooms = Room.all.select do |room|
					room.room_type == "friend"
				end
				new_hash = {}
				heal_rooms.each do |encounter|
					if new_hash[encounter.player_id]
						new_hash[encounter.player_id] += 1
					else 
						new_hash[encounter.player_id] = 1
					end 
				end 
				new_hash.sort_by { |object, value| value }
				new_hash.each do |key, value|
					puts "Player : #{playerz[key].name} has been healed by #{value} friends"
				end 
				check_leaderboards
			when "Most Traps"
				trap_rooms = Room.all.select do |room|
					room.room_type == "trap"
				end
				new_hash = {}
				trap_rooms.each do |encounter|
					if new_hash[encounter.player_id]
						new_hash[encounter.player_id] += 1
					else 
						new_hash[encounter.player_id] = 1
					end 
				end 
				new_hash.sort_by { |object, value| value }
				new_hash.each do |key, value|
					puts "Player : #{playerz[key].name} has been hurt by #{value} traps"
				end 
				check_leaderboards
			when "Exit"
			end 
		
	end


	def highscore
		highscore_menu_choice = selection("Hi, what would you like to do?", ["Check Leaderboard", "Check Stats", "Check Killstory"])
		case highscore_menu_choice
		when "Check Leaderboard"
			check_leaderboards 
		when "Check Stats"

		when "Check Killstory"
		else 
			highscore
		end 

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
				# if choice == "Attack"
				# 	#Code to attack
				# 	#call room #take_dmg
				# 	enemy.take_dmg(@player.attack)
				# 	puts "(　-_･)σ - - - - - - - - ･"
				# 	puts "(∩｀-´)⊃━☆ﾟ.*･｡ﾟ"
				# 	puts "You damaged the enemy for #{@player.attack} amount."
				# elsif choice == "Defend"
				# 	#Code to lower dmg taken
				# 	@player.take_dmg(-1)
				# 	puts "ヽ(ﾟДﾟ)ﾉ"
				# 	puts "You defended"
				# elsif choice == "Run"
				# 	#Code to run
				# 	@player.take_dmg(enemy.attack)
				# 	puts "#{enemy.name} hits you as you try to run."
				# 	puts "{\__/}"
				# 	puts "(●_●)"
				# 	puts "( >🌮"
				# 	puts "You have fled"
				# 	return 
				# else
				# 	puts "¯\_( ͡° ͜ʖ ͡°)_/¯"
				# 	puts "Your Input is invalid, please enter again."
				# 	valid_input = false
				# end



				#enemy AI
				enemy_choice = ["Attack", "Defend", "AFK"].sample
				# if enemy_choice == 1
				# 	#enemy attacks
				# 	@player.take_dmg(enemy.attack)
				# 	puts "#{enemy.name}  attacked you for #{enemy.attack} damage"
				# 	wait(1)

				# elsif enemy_choice == 2
				# 	#enemy looks at u
				# 	puts "#{enemy.name} looks up at the sky."
				# 	wait(1)
				# end

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
		new_hash[:attack] = rand(5..35)
		new_hash[:defense] = rand(1..30)
		new_hash[:max_hp] = rand(60..150)
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
end