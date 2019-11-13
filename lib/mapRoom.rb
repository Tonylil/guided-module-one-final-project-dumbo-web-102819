class MapRoom
	attr_accessor :x, :y, :movable_n, :movable_e, :movable_s, :movable_w

	@@all = []

	def initialize(x, y, n, e, s, w)
		@x = x
		@y = y

		#This is to see if its possible to move, North East South West.
		@movable_n = n
		@movable_e = e
		@movable_s = s
		@movable_w = w

		@@all << self
	end

	def x
		@x
	end

	def is_here(x, y)
		if @x = x && @y = y
			return true
		else
			return false
		end
	end

	def self.all
		@@all
	end

	def self.find_room(x, y)
		@@all.find do |room|
			room.x == x && room.y == y
		end
	end
end