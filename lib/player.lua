Player = class()

Player.radius = 20
Player.collision = {
  shape = 'circle',
  tag = 'player',
  with = {
    wall = function(self, other, dx, dy)
      self.x, self.y = self.x + dx, self.y + dy
      self.shape:moveTo(self.x, self.y)
    end,
    player = function(self, other, dx, dy)
      if other.team ~= self.team then
        dx, dy = dx / 2, dy / 2
        self.x, self.y = self.x + dx, self.y + dy
        ctx.event:emit('collision.move', {object = self, x = self.x, y = self.y})
        other.x, other.y = other.x - dx, other.y - dy
        ctx.event:emit('collision.move', {object = other, x = other.x, y = other.y})
      end
    end
  }
}

----------------
-- Core
----------------
function Player:init()
  self.meta = {__index = self}
  
  self.id = nil
  self.username = ''
  self.class = nil
  self.team = nil
  
  self.x = 0
  self.y = 0
  self.angle = 0
  
  self.slots = {{}, {}, {}, {}, {}}
  self.weapon = 1
  self.skill = 1
  
  self.health = 0
  self.maxHealth = 0
  self.shield = 0
  self.ded = false

  self.lifesteal = 0
  self.haste = 0
  self.cloak = 0

  self.depth = 0
  self.recoil = 0
  self.alpha = 0
end

function Player:activate()
  self.x = ctx.map.spawn[self.team].x
  self.y = ctx.map.spawn[self.team].y

  ctx.event:emit('collision.move', {object = self, x = self.x, y = self.y})
  
  for i = 1, 5 do
    f.exe(self.slots[i].activate, self.slots[i], self)
    if self.slots[i].type == 'skill' and self.skill == self.weapon then self.skill = i end
  end

  self.maxHealth = self.class.health
  self.health = self.maxHealth

  self.depth = -self.id
end

function Player:update()
  if self.recoil > 0 then self.recoil = math.lerp(self.recoil, 0, math.min(5 * tickRate, 1)) end
  self.cloak = timer.rot(self.cloak)
end

function Player:draw()
  local g, c = love.graphics, self.class
  local alpha = self.alpha * (1 - (self.cloak / (self.team == ctx.players:get(ctx.id).team and 2 or 1)))
  g.setColor(0, 0, 0, alpha * 50)
  g.draw(c.sprite, self.x + 4, self.y + 4, self.angle, 1, 1, c.anchorx, c.anchory)
  g.setColor(self.team == purple and {190, 160, 200, alpha * 255} or {240, 160, 140, alpha * 255})
  g.draw(c.sprite, self.x, self.y, self.angle, 1, 1, c.anchorx, c.anchory)
  f.exe(self.slots[self.weapon].draw, self.slots[self.weapon], self)
  f.exe(self.slots[self.skill].draw, self.slots[self.skill], self)
end


----------------
-- Behavior
----------------
function Player:move(input)
  if input.reposition then
    self.x, self.y = input.reposition.x, input.reposition.y
  end

  local w, a, s, d = input.w, input.a, input.s, input.d
  if not (w or a or s or d) then return end
  
  local up, down, left, right, dx, dy = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if not dx then dx = dy end
  if not dy then dy = dx end
  if dx == right and dy == down then dx = 0 end
  
  local dir = (dx + dy) / 2
  local len = (self.class.speed + self.haste) * tickRate
  self.x, self.y = self.x + math.dx(len, dir), self.y + math.dy(len, dir)

  self.x = math.clamp(self.x, 0, ctx.map.width)
  self.y = math.clamp(self.y, 0, ctx.map.height)

  ctx.collision:resolve(self)
  ctx.event:emit('collision.move', {object = self, x = self.x, y = self.y})
end

function Player:turn(input)
  local d = math.direction(self.x, self.y, input.x, input.y)
  self.angle = math.anglerp(self.angle, d, math.min(15 * tickRate, 1))
end

function Player:slot(input)
  input = input or {}

  if input.slot then
    local k = self.slots[input.slot].type
    if self[k] ~= input.slot then
      self[k] = input.slot
      local slot = self.slots[input.slot]
      f.exe(slot.select, slot, self)
    end
  end

  local weapon = self.slots[self.weapon]
  local skill = self.slots[self.skill]
  
  for i = 1, 5 do
    if self.slots[i].type ~= 'weapon' or self.weapon == i then
      f.exe(self.slots[i].update, self.slots[i], self)
    end
  end
  
  if input.l and weapon:canFire(self) then
    weapon:fire(self, input.x, input.y)
    ctx.net:emit(evtFire, {id = self.id, slot = self.weapon})
  end
  
  if input.r and skill:canFire(self) then
    skill:fire(self, input.x, input.y)
    ctx.net:emit(evtFire, {id = self.id, slot = self.skill})
  end

  if input.reload then weapon:reload(self) end
end

Player.hurt = f.empty
Player.heal = f.empty

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
  self.alpha = 0
  ctx.event:emit('collision.detach', {object = self})
end

function Player:spawn()
  self:activate()
end
