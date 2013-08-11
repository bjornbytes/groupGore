SMG = {}
SMG.code = 'smg'
SMG.hp = .15

SMG.activate = function(self)
  self.hp = SMG.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.angle = self.owner.angle + (math.pi / 2)
  
  local endx, endy = self.x + math.cos(self.angle) * 500, self.y + math.sin(self.angle) * 500
  local targets = {}
  Players:with(function(p)
  	return p.team ~= self.owner.team and math.hloca(self.x, self.y, endx, endy, p.x, p.y, 20)
	end, function(p)
		table.insert(targets, {
			id = p.id,
			dist = math.distance(p.x, p.y, self.x, self.y)
		})
	end)
	
	table.sort(targets, function(a, b) return a.dist < b.dist end)
	if targets[1] then
		print('I HIT PLAYER NUMBER ' .. targets[1].id)
	end
end

SMG.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
end

SMG.draw = function(self)
	local alpha = self.hp / .15
  love.graphics.setColor(255, 255, 255, alpha * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * 500, self.y + math.sin(self.angle) * 500)
  love.graphics.setColor(255, 255, 255, 255)
end

return SMG