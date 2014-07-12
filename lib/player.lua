Player = class()

Player.radius = 28
Player.collision = {
  shape = 'circle',
  tag = 'player',
  with = {
    wall = function(self, other, dx, dy)
      if self.z == 0 then
        self.x, self.y = self.x + dx, self.y + dy
      end
    end,
    shortwall = function(self, other, dx, dy)
      if self.z == 0 then
        self.x, self.y = self.x + dx, self.y + dy
      end
    end,
    teamwall = function(self, other, dx, dy)
      if other.team ~= self.team and self.z == 0 then
        self.x, self.y = self.x + dx, self.y + dy
      end
    end,
    player = function(self, other, dx, dy)
      if other.team ~= self.team then
        if self.moving then
          self.x, self.y = self.x + dx, self.y + dy
        end
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
  self.active = false

  self.kills = 0
  self.deaths = 0
  
  self.x = 0
  self.y = 0
  self.z = 0
  self.angle = 0
  self.drawX = 0
  self.drawY = 0
  self.drawAngle = 0
  self.drawScale = 0
  
  self.slots = {}
  self.weapon = 1
  self.skill = 1
  self.weaponDirty = false
  self.skillDirty = false

  self.health = 0
  self.maxHealth = 0
  self.shield = 0
  self.lastHurt = -math.huge
  self.lastDamageDealt = -math.huge
  self.ded = false
  self.killer = nil

  self.lifesteal = 0
  self.haste = 0
  self.cloak = 0
  self.stun = 0
  self.disarm = 0
  self.silence = 0
  self.damageOutMultiplier = 1
  self.damageInMultiplier = 1

  self.depth = 0
  self.recoil = 0
  self.alpha = 0
  self.canvasDirty = true
end

function Player:activate()
  self.active = true
  self.x = ctx.map.spawn[self.team].x
  self.y = ctx.map.spawn[self.team].y
  self.z = 0

  self.weapon = 1
  self.skill = 1
  
  table.each(self.slots, function(slot)
    f.exe(slot.deactivate, slot, self)
  end)
  table.clear(self.slots)
  for i = 1, 5 do
    self.slots[i] = setmetatable({}, {__index = self.class.slots[i]})
    f.exe(self.slots[i].activate, self.slots[i], self)
    if self.slots[i].type == 'skill' and self.skill == self.weapon then self.skill = i end
  end
  
  self.maxHealth = self.class.health
  self.health = self.maxHealth
  self.killer = nil

  ctx.buffs:removeAll(self)
  self.lifesteal = 0
  self.haste = 0
  self.cloak = 0
  self.stun = 0
  self.damageOutMultiplier = 1
  self.damageInMultiplier = 1

  self.depth = -self.id
  self.canvasDirty = true
end

function Player:deactivate()
  self.active = false
  self.username = ''
end

function Player:update()
  if self.recoil > 0 then self.recoil = math.lerp(self.recoil, 0, math.min(5 * tickRate, 1)) end
  self.cloak = timer.rot(self.cloak)
  self.stun = timer.rot(self.stun)
  self.disarm = timer.rot(self.disarm)
  self.silence = timer.rot(self.silence)
  if self.ded then
    self.x, self.y = 0, 0
    ctx.event:emit('collision.move', {object = self})
  end
  if ctx.view then
    self.depth = ctx.view:threeDepth(self.x, self.y, self.z)
    if self.z > 0 then self.depth = self.depth - 100 end
  end
end

function Player:draw()
  local g, c, x, y, a, s = love.graphics, self.class, self.drawX, self.drawY, self.drawAngle, self.drawScale * self.class.scale
  local alpha = self.alpha * (1 - (self.cloak / ((self.team == ctx.players:get(ctx.id).team or (ctx.players:get(ctx.id).killer and ctx.players:get(ctx.id).killer.id == self.id)) and 2 or 1)))
  if self.canvasDirty then self:refreshCanvas() end
  g.setColor(0, 0, 0, alpha * 50)
  g.draw(c.sprite, self.x + 4, self.y + 4, a, s, s, c.anchorx, c.anchory)
  g.setColor(255, 255, 255, alpha * 255)
  g.draw(self.canvas, x, y, a, s, s, self.canvasAnchorX, self.canvasAnchorY)
  g.setColor(self.team == purple and {222, 200, 230, alpha * 255} or {250, 210, 200, alpha * 255})
  g.draw(c.sprite, x, y, a, s, s, c.anchorx, c.anchory)
  f.exe(self.slots[self.weapon].draw, self.slots[self.weapon], self)
end


----------------
-- Behavior
----------------
function Player:move(input)
  if self.stun > 0 then return end

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
  local len = math.max((self.class.speed + self.haste) * tickRate, 0)
  self.x, self.y = self.x + math.dx(len, dir), self.y + math.dy(len, dir)

  self.x = math.clamp(self.x, 0, ctx.map.width)
  self.y = math.clamp(self.y, 0, ctx.map.height)

  self.moving = true
  ctx.collision:update()
  self.moving = nil
end

function Player:turn(input)
  if self.stun > 0 then return end
  local d = math.direction(self.x, self.y, input.x, input.y)
  self.angle = math.anglerp(self.angle, d, math.min(25 * tickRate, 1))
end

function Player:slot(input, prev)
  if self.stun > 0 then return end

  input, prev = input or {}, prev or {}
  local ldown, lpress, lrelease = input.l, input.l and not prev.l, not input.l and prev.l
  local rdown, rpress, rrelease = input.r, input.r and not prev.r, not input.r and prev.r

  if input.slot then
    local k = self.slots[input.slot].type
    if self[k] ~= input.slot and (not self.slots[self[k]] or not self.slots[self[k]].targeting) then
      self[k] = input.slot
      local slot = self.slots[input.slot]
      f.exe(slot.select, slot, self)
      self.canvasDirty = true
    end
  end

  local weapon = self.slots[self.weapon]
  local skill = self.slots[self.skill]
  local function fire(slot)
    local obj = self.slots[slot]
    local msg = {id = self.id, slot = slot, mx = obj.needsMouse and input.x, my = obj.needsMouse and input.y}
    obj:fire(self, input.x, input.y)
    if obj.targeted then obj.targeting = false end
    ctx.net:emit(evtFire, msg)
  end
  
  for i = 1, 5 do
    if self.slots[i].type ~= 'weapon' or self.weapon == i then
      f.exe(self.slots[i].update, self.slots[i], self)
    end
  end

  if lpress and skill.targeting then
    skill.targeting = false
    self.weaponDirty = true
  end

  if rpress and weapon.targeting then
    weapon.targeting = false
    self.skillDirty = true
  end

  if self.disarm == 0 and weapon:canFire(self) then
    if not ldown then self.weaponDirty = false end
    if not self.weaponDirty then
      if lpress then weapon.targeting = weapon.targeted end
      if (weapon.targeted and weapon.targeting and lrelease) or (not weapon.targeted and ldown) then
        fire(self.weapon)
      end
    end
  end

  if self.silence == 0 and skill:canFire(self) then
    if not rdown then self.skillDirty = false end
    if not self.skillDirty then
      if rpress then skill.targeting = skill.targeted end
      if (skill.targeted and skill.targeting and rrelease) or (not skill.targeted and rdown) then
        fire(self.skill)
      end
    end
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
  ctx.event:emit('sound.play', {sound = 'die', x = self.x, y = self.y})
  ctx.buffs:removeAll(self)

  self.alpha = 0
  self.x, self.y = 0, 0
  ctx.event:emit('collision.move', {object = self})
end

function Player:spawn()
  self:activate()
end

function Player:refreshCanvas()
  local g, c, wep = love.graphics, self.class, self.slots[self.weapon]
  local margin = 16
  local w, h = 0, 0
  self = ctx.players:get(self.id)

  if not wep.image then
    self.canvasAnchorX, self.canvasAnchorY = c.anchorx + margin, c.anchory + margin
    w, h = (2 * margin) + c.sprite:getWidth(), (2 * margin) + c.sprite:getHeight()
  else
    local ws = wep.scale / c.scale
    local ax, ay = c.anchorx, c.anchory
    local px1, py1, px2, py2 = 0, 0, c.sprite:getWidth(), c.sprite:getHeight()
    local dx, dy = c.handx - self.recoil, c.handy
    local wx1 = ax + math.dx(dx, 0) - math.dy(dy, 0) - (wep.anchorx * ws)
    local wy1 = ay + math.dy(dx, 0) + math.dx(dy, 0) - (wep.anchory * ws)
    local wx2 = wx1 + wep.image:getWidth() * ws
    local wy2 = wy1 + wep.image:getHeight() * ws
    if wx1 < 0 then
      ax = ax + wx1
      px1, px2 = px1 + wx1, px2 + wx1
      wx1, wx2 = wx1 + wx1, wx2 + wx1
    end
    if wy1 < 0 then
      ay = ay + wy1
      py1, py2 = py1 + wy1, py2 + wy1
      wy1, wy2 = wy1 + wy1, wy2 + wy2
    end
    px1, py1, px2, py2 = px1 + margin, py1 + margin, px2 + margin, py2 + margin
    wx1, wy1, wx2, wy2 = wx1 + margin, wy1 + margin, wx2 + margin, wy2 + margin
    ax, ay = ax + margin, ay + margin
    w, h = math.max(px2, wx2) + margin, math.max(py2, wy2) + margin
    self.canvasAnchorX, self.canvasAnchorY = ax, ay
  end

  if not self.canvas or self.canvas:getWidth() < w or self.canvas:getHeight() < h then
    self.canvas = g.newCanvas(w, h)
    self.backCanvas = g.newCanvas(w, h)
  end

  g.pop()
  if self.team == purple then
    self.canvas:clear(190, 160, 220, 0)
    self.backCanvas:clear(190, 160, 220, 0)
    g.setColor(190, 160, 220)
  else
    self.canvas:clear(240, 160, 140, 0)
    self.backCanvas:clear(240, 160, 140, 0)
    g.setColor(240, 160, 140)
  end
  self.canvas:renderTo(function()
    g.setShader(data.media.shaders.colorize)
    g.draw(c.sprite, self.canvasAnchorX, self.canvasAnchorY, 0, 1, 1, c.anchorx, c.anchory)
    if wep.image then
      local dx, dy = c.handx - self.recoil, c.handy
      local wx = self.canvasAnchorX + math.dx(dx, 0) - math.dy(dy, 0)
      local wy = self.canvasAnchorY + math.dy(dx, 0) + math.dx(dy, 0)
      g.draw(wep.image, wx, wy, 0, wep.scale / c.scale, wep.scale / c.scale, wep.anchorx, wep.anchory)
    end
    g.setShader()
  end)
  data.media.shaders.horizontalBlur:send('amount', .008)
  data.media.shaders.verticalBlur:send('amount', .008)
  g.setColor(255, 255, 255)
  for i = 1, 3 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.backCanvas:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.draw(self.backCanvas)
    end)
  end
  g.setShader()
  ctx.view:worldPush()

  self.canvasDirty = false
end
