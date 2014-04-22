HudFeed = class()

local g = love.graphics
local w, h = g.width, g.height

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
  g.setFont('pixel', 8)
  local alpha = math.min(self.alpha, 1)
  for i = 1, #self.entries do
    local k = self.entries[i]
    g.setColor(0, 0, 0, 200 * alpha)
    g.rectangle('fill', k.x, k.y, w(.14), h(.05))

    local yy = h(.025) - (g.getFont():getHeight() / 2)
    local killer = ctx.players:get(k.kill)
    if killer.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(killer.username, k.x + 8, k.y + yy)

    local victim = ctx.players:get(k.id)
    if victim.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(victim.username, k.x + w(.14) - g.getFont():getWidth(victim.username) - 9, k.y + yy)
  end
end

function HudFeed:insert(data)
  while #self.entries > 3 do table.remove(self.entries, 1) end
  if #self.entries == 3 then self.entries[1].targetX = w() end
  for i = 1, #self.entries do self.entries[i].targetY = self.entries[i].targetY + h(.05) + 4 end
  local t = table.copy(data)
  t.x = w()
  t.y = -h(.05)
  t.targetX = w() - w(.14) - 4
  t.targetY = 4 + h(.07)
  table.insert(self.entries, t)
  self.alpha = 4
end
