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

		case main_screen
		when @choice_string[:start]
			create_characters
			dungeon
		when @choice_string[:highscore]
			puts "Checking Highscore"
		when @choice_string[:exit]
			puts "Thank You for Playing, Have a Nice Day."
		else
			puts "Error, unknown choice"
		end
		#dungeon
	end

	def main_screen
		clear_screen
		puts @choice_string[:start]
		selection("Welcome to Dummy Dungeon v0.01", [@choice_string[:start], @choice_string[:highscore], @choice_string[:exit]])
	end

	def create_characters
		namesies = @prompt.ask("What is your name?") do |q|
			q.required true
			q.validate /\A\w+\Z/
			q.modify   :capitalize
		  end
		#TODO: Ask for name, 
		stats_ok = "Whatever"
		until stats_ok == "Happy"
			new_hash = create_stats 
			stats_ok = selection("Your stats are ATK #{new_hash[:attack]}, DEF #{new_hash[:defense]} and HP #{new_hash[:hp]}. Are you happy or would you like to reroll", ["Happy", "Reroll"])
			#TODO: Rnadom stats, and let user reroll
		end 
		new_hash[:name] = namesies
		#TODO: Create the character (create is combined new + Save)
		puts "Great! #{namesies}, let's start your journey."
		#TODO: Enter the game with the character, aka return the character
		@player = Player.create(new_hash)
	end

	

	def create_stats
		new_hash = {}
		new_hash[:attack] = rand(1..10)
		new_hash[:defense] = rand(1..10)
		new_hash[:max_hp] = rand(15..30)
		new_hash[:hp] = new_hash[:max_hp]
		new_hash
	end 

	def highscore
		
	end

	################## Core Gameplay Functions ##############
	#Move a direction, return the direction
	def dungeon
		while (still_alive?)
			direction = moving
			puts "The direction you moved is #{direction}"

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
	end

	def moving
		valid_input = false

		while(!valid_input)
			direction = selection("You are in room ______. Which direction would you like to choose?", [@choice_string[:n], @choice_string[:e], @choice_string[:s], @choice_string[:w]])
			# puts "You are in room ___. Which direction you want to move?"
			# puts "1) North"
			# puts "2) East"
			# puts "3) South"
			# puts "4) West"

			# direction = gets.chomp.to_i

			clear_screen

			#Making sure the choice is valid
			case direction 
			when @choice_string[:n], @choice_string[:e], @choice_string[:s], @choice_string[:w]
				valid_input = true
			else
				puts "Your Input is invalid, please enter again."
			end 
		end
		direction
	end

	def friend(friend)
		#TODO: Get heal based on room healing varible
		puts "Entered Healing Room"
	end

	def obsticle(obsticle)
		#TODO: Traps, takes damage
		puts "Entered Trap ROom"
	end

	def battle(enemy)
		puts "You encountered a name_temp"
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
					#TODO: Code to attack
					#call room #take_dmg
					enemy.take_dmg(2)
					puts "You damaged the enemy for x amt"
				elsif choice == "Defend"
					#TODO: Code to lower dmg taken
					@player.take_dmg(-1)
					puts "You defended"
				elsif choice == "Run"
					#TODO: Code to run
					@player.take_dmg(1)
					puts "You have fled"
					return 
				else
					puts "Your Input is invalid, please enter again."
					valid_input = false
				end

				#enemy AI
				enemy_choice = rand(1..2)
				if enemy_choice == 1
					#enemy attacks
					@player.take_dmg(1)
					puts "enemy attacked you for 1 damage"
					wait(1)

				elsif enemy_choice == 2
					#enemy looks at u
					puts "...."
					wait(1)
				end
			end 
		end
	end

	def still_alive?
		@player.hp > 0 ? true : false
	end

	################ Helper Functions. ###################
	def clear_screen
		system("clear")
	end

	def wait(time)
		#TODO, freeze the screen for x amt of time
	end

	#Question is a string, choices is an array of strings
	#Returns the choice that u made
	def selection(question, choices)
		@prompt.select(question, choices)
	end
end