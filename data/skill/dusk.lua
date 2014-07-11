local Dusk = {}

Dusk.name = 'Dusk'
Dusk.code = 'dusk'
Dusk.text = 'Move through the shadows.'
Dusk.type = 'skill'

Dusk.needsMouse = true
Dusk.targeted = true
Dusk.cooldown = 8

function Dusk:activate(owner)
  self.timer = 0
  self.targetAlpha = 0
  self.ghostX, self.ghostY = 0, 0
  self.targetGhostX, self.targetGhostY = 0, 0
  self.ghostTick = 0
end

function Dusk:update(owner)
  self.timer = timer.rot(self.timer)
  if self.timer > 1 and owner.cloak > 0 then self.timer = 1 end
  self.targetAlpha = math.lerp(self.targetAlpha, self.targeting and 1 or 0, math.min(10 * tickRate, 1))
  if self.targeting and ctx.view then
    if self.ghostTick == 0 then
      local px, py = self.targetGhostX, self.targetGhostY
      local ox, oy = owner.x, owner.y
      local mx, my = ctx.view:worldMouseX(), ctx.view:worldMouseY()
      local angle = math.direction(ox, oy, mx, my)
      local distance = math.min(data.spell.dusk.maxDistance, math.distance(ox, oy, mx, my))
      self.targetGhostX, self.targetGhostY = ox + math.dx(distance, angle), oy + math.dy(distance, angle)

      local s = 1
      local d = 10
      local tx, ty = self.targetGhostX, self.targetGhostY
      local iter = false
      while ctx.collision:circleTest(tx, ty, owner.radius, {tag = 'wall'}) or tx <= 0 or ty <= 0 or tx >= ctx.map.width or ty >= ctx.map.height do
        tx = self.targetGhostX + math.dx(d * s, angle)
        ty = self.targetGhostY + math.dy(d * s, angle)
        s = -s
        if s == 1 then d = d + 10 end
        iter = true
      end
      if d > 10 or s == -1 then
        s = -s
        while not ctx.collision:circleTest(tx, ty, owner.radius, {tag = 'wall'}) do
          tx = self.targetGhostX + math.dx(d * s, angle)
          ty = self.targetGhostY + math.dy(d * s, angle)
          d = d - 1
        end
      end
      owner.x, owner.y = tx, ty
      owner.moving = true
      owner.ghosting = true
      ctx.collision:update()
      owner.moving = nil
      owner.ghosting = nil
      self.targetGhostX, self.targetGhostY = owner.x, owner.y
      owner.x, owner.y = ox, oy
      ctx.event:emit('collision.move', {object = owner})
      if math.distance(px, py, self.targetGhostX, self.targetGhostY) > 2 then
        self.ghostTick = 1
      else
        self.ghostTick = 6
      end
    end

    local x1, y1 = self.ghostX, self.ghostY
    local x2, y2 = self.targetGhostX, self.targetGhostY
    if x1 == 0 and y1 == 0 then x1, y1 = owner.x, owner.y end
    if x2 == 0 and y2 == 0 then x2, y2 = x1, y1 end
    self.ghostX = math.lerp(x1, x2, math.min(20 * tickRate, 1))
    self.ghostY = math.lerp(y1, y2, math.min(20 * tickRate, 1))

    if self.ghostTick > 0 then self.ghostTick = self.ghostTick - 1 end
  else
    self.targetGhostX, self.targetGhostY = 0, 0
    self.ghostX, self.ghostY = 0, 0
  end
end

function Dusk:canFire(owner)
  return self.timer == 0
end

function Dusk:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.dusk, mx, my)
  self.timer = owner.cloak > 0 and 1 or self.cooldown
  self.targetAlpha = 0
end

function Dusk:gui(owner)
  if self.targetAlpha > 0.1 then
    local g, v = love.graphics, ctx.view
    g.pop()
    ctx.view:worldPush()
    g.setColor(255, 255, 255, self.targetAlpha * 255)
    g.circle('line', owner.drawX, owner.drawY, data.spell.dusk.maxDistance, 100)
    g.setColor(255, 255, 255, self.targetAlpha * 100)
    local x, y = self.ghostX, self.ghostY
    do
      local self = owner
      local g, c, a, s = love.graphics, self.class, self.drawAngle, self.drawScale * self.class.scale
      local alpha = self.alpha * (1 - (self.cloak / ((self.team == ctx.players:get(ctx.id).team or (ctx.players:get(ctx.id).killer and ctx.players:get(ctx.id).killer.id == self.id)) and 2 or 1)))
      g.setColor(0, 0, 0, alpha * 50)
      g.setColor(self.team == purple and {190, 160, 200, alpha * 100} or {240, 160, 140, alpha * 100})
      f.exe(self.slots[self.weapon].draw, self.slots[self.weapon], self)
      f.exe(self.slots[self.skill].draw, self.slots[self.skill], self)
      g.setColor(self.team == purple and {222, 200, 230, alpha * 100} or {250, 210, 200, alpha * 100})
      g.draw(c.sprite, x, y, a, s, s, c.anchorx, c.anchory)
    end
    g.pop()
    g.push()
    g.translate(v.frame.x, v.frame.y)
  end
end

function Dusk:value(owner)
  return self.timer / self.cooldown
end

return Dusk
