HudFeed = class()

local g = love.graphics

function HudFeed:init()
  self.entries = {}
  self.alpha = 0
end

function HudFeed:update()
  for i = 1, #self.entries do
    local k = self.entries[i]
    k.x = math.lerp(k.x, k.targetX, 30 * tickRate)
    k.y = math.lerp(k.y, k.targetY, 30 * tickRate)
  end

  self.alpha = timer.rot(self.alpha)
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
    local width = math.max(u * .14, font:getWidth(killer.username) + font:getWidth(victim.username) + 24)
    g.setColor(0, 0, 0, 200 * alpha)
    g.rectangle('fill', k.x, k.y, width, v * .05)

    local yy = v * .025 - (font:getHeight() / 2)
    if killer.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(killer.username, k.x + 8, k.y + yy)

    if victim.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(victim.username, k.x + width - font:getWidth(victim.username) - 9, k.y + yy)
  end
end

function HudFeed:insert(data)
  local u, v = ctx.hud.u, ctx.hud.v
  while #self.entries > 3 do table.remove(self.entries, 1) end
  if #self.entries == 3 then self.entries[1].targetX = w() end
  for i = 1, #self.entries do self.entries[i].targetY = self.entries[i].targetY + v * .05 + 4 end
  local t = table.copy(data)
  t.x = u
  t.y = -v * .05
  g.setFont('pixel', 8)
  local font = g.getFont()
  local u1, u2 = ctx.players:get(data.kill).username, ctx.players:get(data.id).username
  local width = math.max(u * .14, font:getWidth(u1) + font:getWidth(u2) + 24)
  t.targetX = u - width - 4
  t.targetY = 4 + v * .07
  table.insert(self.entries, t)
  self.alpha = 4
end
