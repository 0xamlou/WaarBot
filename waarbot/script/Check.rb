Player.all.each{|p| p.destroy if not p.alive}
