class Room < ActiveRecord::Base
	has_many :encounter
	has_many :player, through: :encounter
	
	def take_dmg(amt)
		self.hp -= amt
	end

	def get_heal(amt)
		self.hp += amt
		if self.hp > self.max_hp
			self.hp = self.max_hp
		end
	end
end