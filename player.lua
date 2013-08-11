Player = {}

function Player:create()
  return {
    id = nil,
    class = nil,
    team = nil,
    active = false,
    ded = false,
    x = 0,
    y = 0,
    angle = 0,
    speed = 0,
    health = 0,
    maxSpeed = 0,
    maxHealth = 0,
    size = 0,
    anchor = nil,
    slots = {{}, {}, {}, {}, {}},
    buffs = {}
  }
end

function Player:activate()
  self.x = map.spawn[self.team].x
  self.y = map.spawn[self.team].y
  self.maxHealth = self.class.health
  self.maxSpeed = self.class.speed
  self.size = self.class.size
  self.anchor = self.class.anchor
  self.health = self.maxHealth
  for i = 1, 5 do
    self.slots[i].activate(self, self.slots[i])
  end
end

function Player:deactivate()
  self.x, self.y = 0, 0
end

function Player:update()
  assert(self.active)
end

function Player:draw()
  assert(self.class)
  love.graphics.reset()
  if self.team == purple then love.graphics.setColor(190, 160, 220)
  elseif self.team == orange then love.graphics.setColor(240, 160, 140) end
  love.graphics.draw(self.class.sprites.body, self.x, self.y, self.angle, 1, 1, self.anchor.x, self.anchor.y)
  love.graphics.draw(self.class.sprites.head, self.x, self.y, self.angle, 1, 1, self.anchor.x, self.anchor.y) 
end

function Player:move()
  assert(self.input)
  local w, a, s, d = self.input.wasd.w, self.input.wasd.a, self.input.wasd.s, self.input.wasd.d
  if not (w or a or s or d) then return end
  
  local up, down, left, right, speed, dx, dy = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi, self.maxSpeed * tickRate
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if not dx then dx = dy end
  if not dy then dy = dx end
  if dx == right and dy == down then dx = 0 end
  
  local dir = (dx + dy) / 2
  local newx, newy = self.x + math.cos(dir) * speed, self.y + math.sin(dir) * speed
  
  self.x, self.y = CollisionOvw:resolveCircleWall(newx, newy, self.size, .5)
  self.x, self.y = CollisionOvw:resolveCirclePlayer(self.x, self.y, self.size, .5, self.team)
  CollisionOvw:refreshPlayer(self)
  
  if self.x < 0 then self.x = 0
  elseif self.x > map.width then self.x = map.width end
  if self.y < 0 then self.y = 0
  elseif self.y > map.height then self.y = map.height end
end

function Player:turn()
  assert(self.input)
  self.angle = math.direction(self.x, self.y, self.input.mouse.x, self.input.mouse.y)
end

function Player:slot()
  assert(self.input)
  
  for i = 1, 5 do
    if self.slots[i].type ~= 'weapon' or self.input.slot.weapon == i then
      f.exe(self.slots[i].update, self, self.slots[i])
    end
  end
  
  local weapon = self.slots[self.input.slot.weapon]
  if self.input.mouse.l and weapon.canFire(self, weapon) then
    weapon.fire(self, weapon)
  end
end

function Player:buff()
  for _, buff in pairs(self.buffs) do
    f.exe(buff.update, self, buff)
  end
end

function Player:spell(kind)
  Spells:activate(self, kind)
end

function Player:hurt(amount, from)
  if self.ded then return false end
  self.health = math.max(self.health - amount, 0)
  return true
end

function Player:die()
  print('ded')
  self.ded = 5
  self.x = -100
  self.y = -100
  self.health = 0
end

function Player:respawn()
  self.ded = false
  self.x = map.spawn[self.team].x
  self.y = map.spawn[self.team].y
  self.health = self.maxHealth
end