SMG = {}
SMG.code = 'smg'
SMG.hp = .12

SMG.activate = function(self)
  self.hp = SMG.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.angle = self.owner.angle + (math.pi / 2)
  self.len = 900
  
  local x2, y2 = self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len
  local endx, endy = CollisionOvw:checkLineWall(self.x, self.y, x2, y2, true)
  if endx then
    self.len = math.distance(self.x, self.y, endx, endy)
  else
    endx, endy = x2, y2
  end
  
  local targets = {}
  ovw.players:with(function(p)
    return p.active and p.team ~= self.owner.team and math.hloca(self.x, self.y, endx, endy, p.x, p.y, 20)
  end, function(p)
    table.insert(targets, {
      id = p.id,
      dist = math.distance(p.x, p.y, self.x, self.y)
    })
  end)
  
  table.sort(targets, function(a, b) return a.dist < b.dist end)
  if targets[1] then
    local p = ovw.players:get(targets[1].id)
    self.len = math.distance(self.x, self.y, p.x, p.y)
    ovw.net:emit(evtDamage, {id = p.id, amount = data.weapon.smg.damage, from = self.owner.id, tick = tick})
  end
end

SMG.update = function(self)
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
end

SMG.draw = function(self)
  local alpha = self.hp / .12
  love.graphics.setColor(255, 255, 255, alpha * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len)
  love.graphics.setColor(255, 255, 255, 255)
end

return SMG