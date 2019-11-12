class Game

	def initialize(player)
		@player = player
		@prompt = TTY::Prompt.new
	end

	def dungeon_loop
		main_screen

		while (still_alive?)
			direction = moving
			puts "The direction you moved is #{direction}"

			new_room = Room.new({room_type: "combat", enemy_hp: 5})
			if (new_room.room_type == "combat")
				battle(new_room)
			else
				"unknown room type"
			end
		end
	end

	def main_screen
		clear_screen
		puts "Welcome to Dummy Dungeon v0.01"
	end

	################## Core Gameplay Functions ##############
	#Move a direction, return the direction
	def moving
		valid_input = false

		while(!valid_input)
			direction = selection("You are in room ______. Which direction would you like to choose?", ["North", "East", "South", "West"])
			# puts "You are in room ___. Which direction you want to move?"
			# puts "1) North"
			# puts "2) East"
			# puts "3) South"
			# puts "4) West"

			# direction = gets.chomp.to_i

			clear_screen

			#Making sure the choice is valid
			case direction 
			when "North", "East", "South", "West"
				valid_input = true
			else
				puts "Your Input is invalid, please enter again."
			end 
		end
		direction
	end

	def battle(enemy)
		puts "You encountered a name_temp"
		while (enemy.enemy_hp > 0 && @player.current_hp > 0) 

			valid_input = false
			while(!valid_input)
				choice = selection("Your HP: #{@player.current_hp}. Enemy HP: #{enemy.enemy_hp}.", ["Attack", "Defend", "Run"])
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
		@player.current_hp > 0 ? true : false
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