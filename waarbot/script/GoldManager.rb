require 'waar.rb'
Player.all.each do |player|
	puts "Jewing #{player.name}'s gold"
	session = WaarBot::Session.new(player.name, player.password)
	puts session.getXp
	if session.canUpgradeMine then
		session.upgradeGoldMine
		gold = session.getGold
		session.buyArchers(gold / 50)
	else
		gold = session.getGold
		session.buyArchers(gold / 50)
	end
	session.logOut
end
