SMG = {}
SMG.code = 'smg'
SMG.hp = .1

SMG.activate = function(self)
  self.hp = SMG.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.angle = self.owner.angle + (math.pi / 2)
  self.len = 900
  
  local endx, endy = self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len
  local wall = CollisionOvw:checkLineWall(self.x, self.y, endx, endy)
  if wall then
    self.len = math.distance(self.x, self.y, wall[1] + (wall[3] / 2), wall[2] + (wall[4] / 2))
    endx, endy = self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len
  end
  
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
    local p = Players:get(targets[1].id)
    self.len = math.distance(self.x, self.y, p.x, p.y)
    p:hurt(data.weapon.smg.damage, self.owner.id)
  end
end

SMG.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self) end)
end

SMG.draw = function(self)
  local alpha = self.hp / .1
  love.graphics.setColor(255, 255, 255, alpha * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len)
  love.graphics.setColor(255, 255, 255, 255)
end

return SMG