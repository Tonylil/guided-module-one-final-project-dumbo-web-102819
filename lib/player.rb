class Player < ActiveRecord::Base

	#Take Damage
	def take_dmg(amt)
		if amt < 1
			amt = 1
		end
		self.hp -= amt
	end

	def get_heal(amt)
		self.hp += amt
		if self.hp > self.max_hp
			self.hp = self.max_hp
		end
	end

	#TODO: Check Death
	#Check if current Hp is less than 0, return true if dead, false if alive
	def death?

	end
end