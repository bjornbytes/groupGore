HudFeed = class()

local g = love.graphics

function HudFeed:init()
  self.entries = {}
  self.alpha = 0

  ctx.event:on(evtDead, function(data) self:insert(data) end)
end

function HudFeed:update()
  for i = 1, #self.entries do
    local k = self.entries[i]
    k.x = math.lerp(k.x, k.targetX, 30 * tickRate)
    k.y = math.lerp(k.y, k.targetY, 30 * tickRate)
  end

  if love.keyboard.isDown('tab') and self.alpha < 1.5 then
    self.alpha = math.lerp(self.alpha, 1, math.min(30 * tickRate, 1))
  else
    self.alpha = timer.rot(self.alpha)
  end
end

function HudFeed:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  g.setFont('pixel', 8)
  local font = g.getFont()
  local alpha = math.min(self.alpha, 1)
  for i = 1, #self.entries do
    local k = self.entries[i]
    local killer = ctx.players:get(k.kill)
    local victim = ctx.players:get(k.id)
    local width = math.max(math.min(u * .14, 150), font:getWidth(killer.username) + font:getWidth(victim.username) + 24)
    local height = font:getHeight() + 8
    g.setColor(0, 0, 0, 180 * alpha)
    local xx, yy = math.round(k.x) + .5, math.round(k.y) + .5
    g.rectangle('fill', xx, yy, width, height)
    local val = 30 + ((k.kill == ctx.id or k.id == ctx.id) and 225 or 0)
    g.setColor(val, val, val, 180 * alpha)
    g.rectangle('line', xx, yy, width, height)

    if killer.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(killer.username, k.x + 8, k.y + 4)

    if victim.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(victim.username, k.x + width - font:getWidth(victim.username) - 9, k.y + 4)
  end
end

function HudFeed:insert(data)
  local u, v = ctx.hud.u, ctx.hud.v
  g.setFont('pixel', 8)
  local font = g.getFont()
  while #self.entries > 4 do table.remove(self.entries, 1) end
  if #self.entries == 4 then self.entries[1].targetX = u end
  for i = 1, #self.entries do self.entries[i].targetY = self.entries[i].targetY + font:getHeight() + 16 end
  local t = table.copy(data)
  t.x = u
  t.y = -v * .05
  local u1, u2 = ctx.players:get(data.kill).username, ctx.players:get(data.id).username
  t.u1 = u1
  t.u2 = u2
  local width = math.max(math.min(u * .14, 150), font:getWidth(u1) + font:getWidth(u2) + 24)
  t.targetX = u - width - 4
  t.targetY = 4 + v * .07
  table.insert(self.entries, t)
  self.alpha = 4
end

function HudFeed:resize()
  local u, v = ctx.hud.u, ctx.hud.v
  g.setFont('pixel', 8)
  local font = g.getFont()
  for i = 1, #self.entries do
    local entry = self.entries[i]
    local width = math.max(math.min(u * .14, 150), font:getWidth(entry.u1) + font:getWidth(entry.u2) + 24)
    entry.targetX = u - width - 4
    if i == 1 and #self.entries == 5 then
      entry.targetX = u
    end
    entry.x = entry.targetX
    entry.targetY = 4 + (v * .07) + ((#self.entries - i) * (font:getHeight() + 16))
    entry.y = entry.targetY
  end
end
