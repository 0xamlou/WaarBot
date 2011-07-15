require 'waar.rb'
class Player < ActiveRecord::Base
	def alive
		session = WaarBot::Session.new(name, password)
		session.logOut
		return session.isValid
	end
	def updateStats
		Thread.start do
			session    = WaarBot::Session.new(name, password)
			stats      = session.getPlayerStats
			self.state      = stats[:standBy]
			self.may_attack = stats[:canAttack] 
			self.soldiers   = stats[:soldiers] 
			self.knights    = stats[:knights] 
			self.heroes     = stats[:heroes] 
			self.archers    = stats[:archers] 
			self.gold       = stats[:gold] 
			self.xp         = stats[:xp] 
			self.mine       = stats[:mineLevel] 
			self.save
		end
	end
	
	def probeThem
		Thread.start do
			session = WaarBot::Session.new(name, password)
			session.probeTargets
		end
	end

	validates_uniqueness_of :name

end
