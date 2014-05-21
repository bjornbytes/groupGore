Player = class()

----------------
-- Core
----------------
function Player:init()
  self.id = nil
  self.username = ''
  self.class = nil
  self.team = nil
  self.active = false
  self.ded = false
  self.x = 0
  self.y = 0
  self.angle = 0
  self.speed = 0
  self.health = 0
  self.shield = 0
  self.maxSpeed = 0
  self.maxHealth = 0
  self.lifesteal = 0
  self.collision = {
    shape = 'circle',
    tag = 'player',
    with = {
      wall = function(self, other, dx, dy)
        self.x, self.y = self.x + dx, self.y + dy
        self.shape:moveTo(self.x, self.y)
      end,
      player = function(self, other, dx, dy)
        if self.speed > 0 and other.team ~= self.team then
          self.x, self.y = self.x + dx, self.y + dy
          self.shape:moveTo(self.x, self.y)
        end
      end
    }
  }
  self.radius = 0
  self.depth = 0
  self.recoil = 0
  self.visible = 0
  self.lastHurt = 0
  self.slots = {{}, {}, {}, {}, {}}
  self.weapon = 1
  self.skill = 1  
end

function Player:activate()
  self.x = ctx.map.spawn[self.team].x
  self.y = ctx.map.spawn[self.team].y
  self.maxHealth = self.class.health
  self.maxSpeed = self.class.speed
  self.health = self.maxHealth
  self.radius = self.class.size
  self.depth = -self.id
  for i = 1, 5 do
    f.exe(self.slots[i].activate, self, self.slots[i])
    if self.slots[i].type == 'skill' and self.skill == self.weapon then self.skill = i end
  end
  ctx.event:emit('collision.attach', {object = self})
end

function Player:deactivate()
  self.x, self.y = 0, 0
  self.username = ''
  ctx.event:emit('collision.detach', {object = self})
end

Player.update = f.empty

function Player:draw()
  love.graphics.setColor(0, 0, 0, self.visible * 50)
  love.graphics.draw(self.class.sprite, self.x + 4, self.y + 4, self.angle, 1, 1, self.class.anchorx, self.class.anchory)
  if self.team == purple then love.graphics.setColor(190, 160, 220, self.visible * 255)
  elseif self.team == orange then love.graphics.setColor(240, 160, 140, self.visible * 255) end
  if self.hurtHistory then love.graphics.setColor(255, 255, 255, 200) end
  love.graphics.draw(self.class.sprite, self.x, self.y, self.angle, 1, 1, self.class.anchorx, self.class.anchory)
  f.exe(self.slots[math.ceil(self.weapon)].draw, self, self.slots[math.ceil(self.weapon)])
  f.exe(self.slots[math.ceil(self.skill)].draw, self, self.slots[math.ceil(self.skill)])

  if self.shape and love.keyboard.isDown(' ') then
    if self.team == purple then love.graphics.setColor(190, 160, 220, self.visible * 100)
    elseif self.team == orange then love.graphics.setColor(240, 160, 140, self.visible * 100) end
    self.shape:draw('fill')
    if self.team == purple then love.graphics.setColor(190, 160, 220, self.visible * 255)
    elseif self.team == orange then love.graphics.setColor(240, 160, 140, self.visible * 255) end
    self.shape:draw('line')
  end
end


----------------
-- Behavior
----------------
function Player:move(input)
  local w, a, s, d = input.w, input.a, input.s, input.d
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
  elseif self.x > ctx.map.width then self.x = ctx.map.width end
  if self.y < 0 then self.y = 0
  elseif self.y > ctx.map.height then self.y = ctx.map.height end

  ctx.collision:resolve(self)
end

function Player:turn(input)
  local d = math.direction(self.x, self.y, input.x, input.y)
  self.angle = math.anglerp(self.angle, d, math.min(15 * tickRate, 1))
end

function Player:slot(input)
  if self.ded then return end

  if input.slot then
    self[self.slots[input.slot].type] = input.slot
  end
  
  for i = 1, 5 do
    if self.slots[i].type ~= 'weapon' or self.weapon == i then
      f.exe(self.slots[i].update, self, self.slots[i])
    end
  end
  
  local weapon = self.slots[self.weapon]
  if input.l and weapon.canFire(self, weapon) then
    ctx.net:emit(evtFire, {id = self.id, slot = self.weapon})
  end

  if input.reload then
    weapon.reload(self, weapon)
  end
  
  local skill = self.slots[self.skill]
  if input.r and skill.canFire(self, skill) then
    ctx.net:emit(evtFire, {id = self.id, slot = self.skill})
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
 
  ctx.event:emit('particle.create', {
    kind = 'skull',
    vars = {x = self.x, y = self.y}
  })
  ctx.event:emit('particle.create', {
    kind = 'gib',
    count = 64,
    vars = {x = self.x, y = self.y}
  })
  ctx.event:emit('sound.play', {sound = 'die'})
  ctx.buffs:removeAll(self)  

  self.x, self.y = 0, 0
  self.visible = 0
  ctx.event:emit('collision.detach', {object = self})
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
