class Room < ActiveRecord::Base
	def take_dmg(amt)
		self.enemy_hp -= amt
	end
end