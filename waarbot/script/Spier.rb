require 'waar.rb'
Player.all[1..Player.all.length - 1].each do |spy|
	puts "Our spy is #{spy}! xp : #{spy.xp}"
	spy.destroy if not spy.alive
	session = WaarBot::Session.new(spy.name, spy.password)
	targets = Target.find(:all, :conditions => {:xp => ((spy.xp - 20)..(spy.xp + 20))})
	n = targets.length
	puts "got #{n} targets"
	i = 0
	spy.updateStats
	while i < n  and spy.gold > 200 do
		puts "#{spy} to spy on #{targets[i].name} with #{spy.gold} gold left"
		res = session.spy(targets[i].name, targets[i].ingame_id)
		if res != nil then
			spy.gold = session.getGold
			puts "Got #{targets[i].name} who has #{res[:gold]} | #{res[:population]} ..#{spy.gold} g left"
			targets[i].gold = res[:gold]
			targets[i].population = res[:population]
			spy.save
			targets[i].save
		else
			puts "NO RESULT ! ! :("
		end
		i += 1
	end
	session.logOut
end

