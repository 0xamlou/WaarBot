module WaarBot

class Session	
	def initialize(username, password, proxyaddress=nil)
		@username, @password = username, password
		@waarPage = Mechanize.new {|agent| agent.user_agent_alias = 'Linux Firefox'}
		setProxy(proxyaddress) if proxyaddress
		@valid = logIn
	end

	def isValid
		@valid
	end

	def setProxy(proxyaddress)
		ip = proxyaddress.scan(/[0-9,.]{1,}/)[0]
		port = proxyaddress.scan(/[0-9,.]{1,}/)[1]
		@waarPage.set_proxy(ip,port)
		puts "proxy set for #{@username}"
	end
	
	def showPage(body)
		pagun = File.open("#{@username}.html",'w')
		pagun.write(body)
		pagun.close
		system("firefox pagina.html")
	end

	def logIn
		@waarPage.get('http://waar.fr/') do |page|
			search_result = page.form_with(:action => '/actions/general/connexion.php') do |search|
				search.psd = @username
				search.mdp = @password
			end.submit
		end
		return @waarPage.page.body.scan(/n'existe/) == []
	end
	
	def logOut
		@waarPage.get('http://waar.fr/actions/general/deconnexion.php')
	end
	
	def deleteAccount(password)
		puts 'deleting account ..'
		@waarPage.post('http://waar.fr/actions/compte/supprimer_compte.php', 'mdp' => password )
	end

	def spy(targetName, targetID)
		@waarPage.get "http://waar.fr/actions/jeu/espionner.php?id=#{targetID}"
		res = @waarPage.page.body.scan(/#{targetName.capitalize}.*xp : \d{1,}/)
		if res == [] then
			return nil
		else
			gold = @waarPage.page.body.scan(/or">.*?</)[0]
			gold.gsub!(' ','')
			gold.slice! 'or">'
			gold.slice! '<'
			res = res[0].scan(/or.*/).first.gsub(' ', '')
			return { :gold => (res.scan(/\d{1,}/)[0]).to_i, :population => (res.scan(/\d{1,}/)[1]).to_i, :gold_left => gold.to_i }
		end

	end

	def getXp
		xp = ''
		@waarPage.get('http://waar.fr/royaume.php') do |page|
			xp = page.body.scan(/xp">.*?</)[0]
			if xp then
				xp.slice! 'xp">'
				xp.slice! '<'
				xp.gsub!(' ','')
			else
				return nil
			end
	
		end
		return xp.to_i
	end
	
	def getPlayerStats		
		mineLevel = 0
		canAttack = 0
		gold      = 0
		xp        = 0
#		rank      = 0
		soldiers  = 0
		heroes    = 0
		knights   = 0
		archers   = 0
		standBy   = false
		
		@waarPage.get('http://waar.fr/mine.php') do |page|
			mineLevel = page.body.scan(/Niveau \d+/)[0]
			mineLevel = mineLevel.gsub('Niveau ','')
		end		
		
		@waarPage.get('http://waar.fr/royaume.php') do |page|
			xp = page.body.scan(/xp">.*?</)[0]
			xp.slice! 'xp">'
			xp.slice! '<'
			xp.gsub!(' ','')
			gold = page.body.scan(/or">.*?</)[0]
			gold.gsub!(' ','')
			gold.slice! 'or">'
			gold.slice! '<'
			standBy = page.body.scan(/Le mode veille est activ/) != []

		end
#		We do not need this for now
#		@waarPage.get('http://waar.fr/classement.php') do |page|
#			rank = page.body.scan(/classement.php\?page=\d{1,}">.*?</)[0].to_s
#			rank.slice! rank.scan(/classement.php\?page=\d{1,}">/)[0].to_s
#			rank.slice! '<'
#			rank.slice! '~'
#			rank.gsub!(' ','')
#		end
		
		@waarPage.get('http://waar.fr/armee.php') do |page|
			canAttack = page.body.scan(/all>\d/)[0]
			canAttack.gsub!('all>','')
			canAttack = canAttack.to_i

			soldiers = page.body.scan(/soldats">.*?</)[1]
			soldiers.slice!('soldats">')
			soldiers.slice!('<')
			knights  = page.body.scan(/chevaliers">.*?</)[1]
			knights.slice!('chevaliers">')
			knights.slice!('<')
			heroes = page.body.scan(/heros">.*?</)[1]
			heroes.slice!('heros">')
			heroes.slice!('<')
			archers  = page.body.scan(/archers">.*?</)[1]
			archers.slice!('<')
			archers.slice!('archers">')
		end
			
		{
			:standBy  => standBy,
			:canAttack=> canAttack,
			:soldiers => soldiers.gsub(' ','').to_i,
			:knights  => knights.gsub(' ','').to_i,
			:heroes   => heroes.gsub(' ','').to_i,
			:archers  => archers.gsub(' ','').to_i,
			:gold     => gold.to_i,
			:xp       => xp.to_i,
#			:rank     => rank.to_i,
			:mineLevel=> mineLevel.to_i
		}
	end
	def  allianceJoinRequest(allianceId)
		@waarPage.get("http://waar.fr/actions/alliance/candidater_alliance.php?id=#{allianceId}")
	end
	
	def giveArchers(howMany)
		@waarPage.post('http://waar.fr/actions/alliance/armee_alliance.php', 'nb3' => howMany)
	end

	def upgradeGoldMine	
		@waarPage.get('http://waar.fr/actions/jeu/evoluer_mine.php')
	end

	def buyArchers(howMany)	
		@waarPage.post('http://waar.fr/actions/jeu/armee.php', 'nb3' => howMany)
	end

	def buyHeros(howMany= 'max')
		if (howMany == 'max') then
			maxHerosLink = ''
			@waarPage.get('http://waar.fr/armee.php') do |page|
				maxHerosLink = page.body.scan(/\/actions\/jeu\/armee.php\?unite=4&nb=\d{1,}/)[0]
			end
			if maxHerosLink != nil then
				@waarPage.get(maxHerosLink) do |page|
				puts maxHerosLink.scan(/\d{1,}/)[1].to_s + ' Heros Created!'
				end
			else
				puts 'Not enough gold'
			end
		end
	end
	
	def attack(id, canAttack)
		canAttack_ = canAttack
		@waarPage.get("http://waar.fr/actions/jeu/attaquer.php?id=#{id}") do |page|
			tinlet = page.body.scan(/all>\d/)[0]
			tinlet.gsub!('all>','')
			canAttack_ = tinlet.to_i 
			puts 'u may still attack ' + tinlet + ' times'
		end
		return canAttack_
	end

def extractXpList(body)
	res  = body.scan(/<td>\d{1,}<\/td>/)
	n = res.length / 2
	n.times do |c|
		res.slice! c
	end
	res.each_with_index { |e, i| res[i].gsub!('<td>', ''); res[i].gsub!('</td>','')}
end

def extractInfo(playa)
	
	@waarPage.get "http://www.waar.fr/#{playa}"
	puts "http://www.waar.fr/#{playa}"
	xp = @waarPage.page.body.scan(/\d{1,} xp/)[0].gsub(' xp', '')
	xp = xp.to_i
	name = @waarPage.page.body.scan(/pseudo=[a-zA-Z0-9_]{1,}/)[0].gsub('pseudo=', '')
	id   = playa.gsub('joueur.php?id=', '')
	state = 0
	if @waarPage.page.body.scan(/actif/) != [] then state = 1
	elsif @waarPage.page.body.scan(/inactif/) != [] then state = 2
	elsif @waarPage.page.body.scan(/veille/) != [] then state = 3
	elsif @waarPage.page.body.scan(/vacance/) != [] then state = 4
	elsif @waarPage.page.body.scan(/mort/) != [] then state = 5
	end
	{
		:name  => name,
		:xp    => xp,
		:state => state,
		:id    => id
	}
end

def getRankBounds(xpmin, xpmax)
	@waarPage.page.links[5].click
	pos = @waarPage.page.links[10].href.scan(/=\d{1,}/)[0].gsub('=','')
	posmin = posmax = pos = pos.to_i
	begin
		@waarPage.get "http://www.waar.fr/classement.php?page=#{posmin}"
		res = extractXpList(@waarPage.page.body)
		posmin += 1
	end while (res.last).to_i >= xpmin and (res.first.to_i >= 7)
	posmin -= 1
	begin
		@waarPage.get "http://www.waar.fr/classement.php?page=#{posmax}"
		res = extractXpList(@waarPage.page.body)
		posmax -= 1
	end while (res.first).to_i <= xpmax
	
	{
		:posmin => posmin,
		:posmax => posmax
	}
end

def probeTargets
	@waarPage.post 'http://www.waar.fr/actions/general/connexion.php', 'psd' => @username, 'mdp' => @password
	puts "Logged on with #{@username} : #{@password}"
	begin
		xp = getXp
	end while xp == nil
	xpmin = xp - 20
	xpmax = xp + 20

	pos = getRankBounds(xpmin, xpmax)
	posmin = pos[:posmin]
	posmax = pos[:posmax]
	pos = posmin
	while pos >= posmax
		puts "Page #{pos}"
		puts
		@waarPage.get "http://www.waar.fr/classement.php?page=#{pos}"
		players = @waarPage.page.body.scan(/joueur.php\?id=\d{1,}/)
		players.slice! 0
		players.each do |playa|
			infos = extractInfo(playa)
			target = Target.new
			target.name		= infos[:name]
			target.ingame_id	= infos[:id]
			target.state		= infos[:state]
			target.xp		= infos[:xp]
			if target.state != 5 then
				target.save 
				puts "saved target |name: #{target.name} |id: #{target.ingame_id} |state: #{target.state} |xp: #{target.xp}"
			end
		end
		
		pos -= 1
	end
end

end

class Playerk
	
	def goStandBy	#TODO yet to be done
		@waarPage.get('http://waar.fr/mode_veille.php')
	end
	
	def updateStats
		@stats = session.getPlayerStats
	end
	
	def buyArchers
		howMany = @stats[:gold] / 50
		if howMany > 0 then
			@session.buyArchers((@stats[:gold]/goldDividedBy.to_i)/50)
			puts "bought #{howMany} archers !"
		else
			puts 'not enough gold..'
		end
	end

	def tellStats
		puts "#{@username} #{'(on standby) ' if @stats[:standBy]}has : \n #{@stats[:gold]} gold, #{@stats[:xp]} xp, mine level #{@stats[:mineLevel]}, may attack #{@stats[:canAttack]} times and is ranked #{@stats[:rank]}\n#{@stats[:soldiers]} soldiers, #{@stats[:knights]} knights, #{@stats[:archers]}archers, #{@stats[:heroes]} heroes"
	end
	def attack	#TODO yet to be done
		thereAreVicts = true
		File.open("victims.ws","r") do |file|			
			while @stats[:canAttack] > 0 and thereAreVicts and line = file.gets
				victimId = line.scan(/^.*?;/)[0]
				victimXp = line.scan(/;\d+/)[0]
				victimId.slice! ';'
				victimXp.slice! ';'
				if @stats[:xp] <= victimXp.to_i + 20 and @stats[:xp] >= victimXp.to_i - 20 then
					i = 0
					gotXpFromAttacking = true
					while i < 3 and gotXpFromAttacking and @stats[:canAttack] > 0
						puts "attacking #{victimId} who has #{victimXp} xp"
						canAttack_ = @session.attack(victimId, @stats[:canAttack])
						newXp = @session.getXp 
						if @stats[:xp] == newXp
							gotXpFromAttacking = false
							puts 'ouch!' if @stats[:canAttack] != canAttack_
						else
							@stats[:xp] = newXp
							puts "attacking again..(#{canAttack_})"
						end
						@stats[:canAttack] = canAttack_
						i += 1						
					end
				else
					thereAreVicts = false if @stats[:xp] < victimXp.to_i - 20 
					
					puts "#{victimId} xp out of range (#{victimXp})"
				end
			end
		end
	end

	def upgradeGoldMine	#TODO yet to be done
		@session.upgradeGoldMine
	end

	def goStandBy	#TODO yet to be done
		@session.goStandBy
		@stats[:standBy] = true
	end

	def deleteAccount
		@session.deleteAccount(@password)
	end
	
	def saveProgress
		updateStats
		outputString = ((Time.now.to_i - 1295887219)/86400 ).to_s	#Vandalism in India
		outputString << ';'
		outputString << @stats[:gold].to_s 
		outputString << ';'
		outputString << @stats[:xp].to_s
		outputString << ';'
		outputString << @stats[:rank].to_s
		outputString << ';'	
		outputString << @stats[:soldiers].to_s
		outputString << ';'
		outputString << @stats[:knights].to_s 
		outputString << ';'
		outputString << @stats[:archers].to_s 
		outputString << ';'
		outputString << @stats[:heroes].to_s 
		outputString << ';'
		unless File.exists?(@usernamproxyaddresse + '.csv')
			File.open(@username + '.csv',"w+") do |file|
			file.puts('"timestamp";"gold";"xp";"rank";"soldiers";"knights";"archers";"heroes"')
			end
		end
		File.open(@username + '.csv',"a+") do |file|
			file.puts(outputString)
		end
	end
	
	def allianceJoinRequest(allianceId)
		@session.allianceJoinRequest(allianceId)
		puts "Requested Joining Alliance #{allianceId}"
	end

	def giveAllArchers
		puts "giving #{@stats[:archers]} to alliance .."
		@session.giveArchers(@stats[:archers])
	end
	

	attr_reader :username, :password, :proxyaddress, :session, :stats ,:usesproxy
end

end	#end of module
