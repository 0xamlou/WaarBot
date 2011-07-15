require 'waar.rb'
$Inf = 1.0 / 0.0
Player.all.each do |player|

	targets = Target.find(:all, :conditions =>{:xp => (player.xp - 20)..(player.xp + 20), :population => 0..player.archers }, :order => 'gold desc')
	n = targets.length
	puts "#{player.name} has #{n} potential targets."
	i = 0
	player.updateStats
	session = WaarBot::Session.new(player.name, player.password)
	while(player.may_attack > 0 and i < n) do
		puts "Attacking #{targets[i].name}.."
		3.times{player.may_attack = session.attack(targets[i].ingame_id, player.may_attack)}
		i += 1
	end
	session.logOut
	player.updateStats

end
		











