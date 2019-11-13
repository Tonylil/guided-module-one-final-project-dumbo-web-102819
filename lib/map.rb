class Map
	attr_accessor :x, :y, :current_room
	def initialize(row, col)
		@x = 0
		@y = 0

		#max map size
		@row = row
		@col = col

		#Creating the rooms in the map
		row.times do |r|
			col.times do |c|
				#Which direction u r allowed to move
				#assume we are allow to move in all direction at first
				n = true
				e = true
				s = true
				w = true

				#If we are all the way at the left
				if c == 0
					w = false
				end
				#If we are all the way at the top
				if r == 0
					n = false
				end
				#If we are all the way at the right
				if c == @col - 1
					e = false
				end
				#If we are all the way at the bot
				if r == @row - 1
					s = false
				end

				#Create a new room
				MapRoom.new(r, c, n, e, s, w)
			end
		end

		#setting the current room
		@current_room = MapRoom.find_room(0, 0)
	end

	######### Moving within the map, returns true if moved, false if cannot move.
	def move(direction)
		case direction
		when "North"
			move_north
		when "East"
			move_east
		when "South"
			move_south
		when "West"
			move_west
		end
	end

	def move_north
		if current_room.movable_n
			#update the loction
			@y -= 1
			update_current_room
			return true
		else
			return false
		end
	end

	def move_east
		if current_room.movable_e
			#update the loction
			@x += 1
			update_current_room
			return true
		else
			return false
		end
	end

	def move_south
		if current_room.movable_s
			#update the loction
			@y += 1
			update_current_room
			return true
		else
			return false
		end
	end

	def move_west
		if current_room.movable_w
			#update the loction
			@x -= 1
			update_current_room
			return true
		else
			return false
		end
	end

    def update_current_room
    	@current_room = MapRoom.find_room(@y, @x)
    end

	def show_map()
		@row.times do |r|
			#Start with an empty line for the row
			line = ""
			#This is drawing the line below for the connection
			line_below = ""
			@col.times do |c|
				#Prints the room and the connections
				room = MapRoom.find_room(r, c)

				#Start with an opening to the room
				line << " ["
				line_below << "  "

				#Checks if you are in this room
				if room == @current_room
					#if u are, put an symbol to mark you are here
					line << "x"
				else
					#if u aren't, put an empty space
					line << " "
				end

				#check if line_below has a connection
				if room.movable_s
					line_below << "|"
				else
					line_below << " "
				end

				#now finish making the room, and add space
				line << "] "
				line_below << "   "

				#Check if there's an connection with the next room to the right
				if room.movable_e
					#if connection, draw a line
					line << "-"
				else
					#if no connection, empty space
					line << " "
				end
			end
			#Now Prints this line, and the connection below it
			puts line
			puts line_below
		end
	end
end