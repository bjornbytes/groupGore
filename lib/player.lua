Player = {}

----------------
-- Core
----------------
function Player:create()
  return {
    id = nil,
    username = '',
    class = nil,
    team = nil,
    active = false,
    ded = false,
    x = 0,
    y = 0,
    angle = 0,
    speed = 0,
    health = 0,
    shield = 0,
    maxSpeed = 0,
    maxHealth = 0,
    lifesteal = 0,
    collision = {
      shape = 'circle',
    },
    radius = 0,
    depth = 0,
    recoil = 0,
    visible = 0,
    lastHurt = 0,
    slots = {{}, {}, {}, {}, {}}
  }
end

function Player:activate()
  self.x = ovw.map.spawn[self.team].x
  self.y = ovw.map.spawn[self.team].y
  self.maxHealth = self.class.health
  self.maxSpeed = self.class.speed
  self.health = self.maxHealth
  self.radius = self.class.size
  for i = 1, 5 do
    f.exe(self.slots[i].activate, self, self.slots[i])
  end
end

function Player:deactivate()
  self.x, self.y = 0, 0
  self.username = ''
end

function Player:update()
  assert(self.active)
end

function Player:draw()
  assert(self.class)
  love.graphics.reset()
  love.graphics.setColor(0, 0, 0, self.visible * 50)
  love.graphics.draw(self.class.sprite, self.x + 4, self.y + 4, self.angle, 1, 1, self.class.anchorx, self.class.anchory)
  if self.team == purple then love.graphics.setColor(190, 160, 220, self.visible * 255)
  elseif self.team == orange then love.graphics.setColor(240, 160, 140, self.visible * 255) end
  if self.hurtHistory then love.graphics.setColor(255, 255, 255, 200) end
  love.graphics.draw(self.class.sprite, self.x, self.y, self.angle, 1, 1, self.class.anchorx, self.class.anchory)
  if self.input then
    f.exe(self.slots[math.ceil(self.input.weapon)].draw, self, self.slots[math.ceil(self.input.weapon)])
    f.exe(self.slots[math.ceil(self.input.skill)].draw, self, self.slots[math.ceil(self.input.skill)])
  end
end


----------------
-- Behavior
----------------
function Player:move()
  assert(self.input)
  local w, a, s, d = self.input.w, self.input.a, self.input.s, self.input.d
  local moving = w or a or s or d
  
  local up, down, left, right, dx, dy = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
  
  if moving then
    self.speed = self.maxSpeed
  else
    self.speed = 0
  end
  
  if self.speed == 0 then return end
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if dx or dy then
    if not dx then dx = dy end
    if not dy then dy = dx end
    if dx == right and dy == down then dx = 0 end
    
    local dir = (dx + dy) / 2
    self.x, self.y = self.x + math.cos(dir) * (self.speed * tickRate), self.y + math.sin(dir) * (self.speed * tickRate)
  end
  
  if self.x < 0 then self.x = 0
  elseif self.x > ovw.map.width then self.x = ovw.map.width end
  if self.y < 0 then self.y = 0
  elseif self.y > ovw.map.height then self.y = ovw.map.height end
end

function Player:turn()
  assert(self.input)
  self.angle = math.anglerp(self.angle, math.direction(self.x, self.y, self.input.mx, self.input.my), .35)
end

function Player:slot()
  assert(self.input)
  
  if self.ded then return end
  
  for i = 1, 5 do
    if self.slots[i].type ~= 'weapon' or self.input.weapon == i then
      f.exe(self.slots[i].update, self, self.slots[i])
    end
  end
  
  local weapon = self.slots[self.input.weapon]
  if self.input.l and weapon.canFire(self, weapon) then
    ovw.net:emit(evtFire, {id = self.id, slot = self.input.weapon})
  end
  
  local skill = self.slots[self.input.skill]
  if self.input.r and skill.canFire(self, skill) then
    ovw.net:emit(evtFire, {id = self.id, slot = self.input.skill})
  end
  
  if self.recoil > 0 then self.recoil = self.recoil - math.min(self.recoil, 8 * tickRate) end
end

function Player:hurt()
  self.lastHurt = tick
end

function Player:heal()
  --
end

function Player:die()
  self.ded = 5
  if ovw.particles then ovw.particles:create('skull', {x = self.x, y = self.y}) end
  if ovw.sound then ovw.sound:play('die') end
  ovw.buffs:remove(self.id)

  self.x, self.y = 0, 0
  self.visible = 0
end

function Player:spawn()
  self:activate()
end

function Player:copy()
  local t = {
    id = self.id,
    class = self.class,
    team = self.team,
    ded = self.ded,
    x = self.x,
    y = self.y,
    angle = self.angle,
    speed = self.speed,
    health = self.health,
    shield = self.shield,
    recoil = self.recoil,
    visible = self.visible,
    slots = table.copy(self.slots)
  }
  
  setmetatable(t, {__index = self})
  return t
end
