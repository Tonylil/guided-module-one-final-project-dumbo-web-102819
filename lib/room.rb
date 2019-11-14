class Room < ActiveRecord::Base
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
end