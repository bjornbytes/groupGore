Player = {}

function Player:create()
  return {
    id = nil,
    class = nil,
    team = nil,
    active = false,
    x = 0,
    y = 0,
    angle = 0,
    slots = {{}, {}, {}, {}, {}},
    buffs = {}
  }
end

function Player:activate()
  self.x = 400
  self.y = 300
  for i = 1, 5 do
    self.slots[i].activate(self, self.slots[i])
  end
end

function Player:deactivate()
  self.x, self.y = f.dbl(0)
end

function Player:update()
  assert(self.active)
end

function Player:draw()
  assert(self.class)
  love.graphics.draw(self.class.sprite, self.x, self.y, self.angle, 1, 1, self.class.sprite:getWidth() / 2, self.class.sprite:getHeight() / 2)
end

function Player:move()
  assert(self.input)
  local w, a, s, d = self.input.wasd.w, self.input.wasd.a, self.input.wasd.s, self.input.wasd.d
  if not (w or a or s or d) then return end
  
  local up, down, left, right, speed, dx, dy = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi, self.class.speed * tickRate
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if not dx then dx = dy end
  if not dy then dy = dx end
  if dx == right and dy == down then dx = 0 end
  
  local dir = (dx + dy) / 2
  local newx, newy = self.x + math.cos(dir) * speed, self.y + math.sin(dir) * speed
  
  self.x, self.y = CollisionOvw:resolveCircle(newx, newy, 16, .5)
end

function Player:turn()
  assert(self.input)
  self.angle = math.direction(self.x, self.y, self.input.mouse.x, self.input.mouse.y)
end

function Player:slot()
  assert(self.input)
  
  local weapon = self.slots[self.input.slot.weapon]
  weapon.update(self, weapon)
  
  if self.input.mouse.l and weapon.canFire(self, weapon) then
    weapon.fire(self, weapon)
  end
end

function Player:spell(kind)
  assert(kind)
  Spells:activate(self.id, kind)
end