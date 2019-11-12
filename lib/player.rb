class Player < ActiveRecord::Base

	#Take Damage
	def take_dmg(amt)
		self.hp -= amt
	end

	#TODO: Check Death
	#Check if current Hp is less than 0, return true if dead, false if alive
	def death?

	end
end