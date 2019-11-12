class Room < ActiveRecord::Base
	def take_dmg(amt)
		self.hp -= amt
	end
end