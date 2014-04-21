HudBlood = class()

function HudBlood:init()
  self.images = {}
  for i = 1, 4 do
    self.images[i] = love.graphics.newImage('media/graphics/hud/hudBlood' .. i .. '.png')
  end
end

function HudBlood:draw()
  local p = ctx.players:get(ctx.id)
  if p and p.active then
    local hp = math.lerp(ctx.hud.health.prevVal, ctx.hud.health.val, tickDelta / tickRate)
    local prc = hp / p.maxHealth
    local image = self.images[4 - math.floor(math.min(prc * 8, 3))]
    love.graphics.setColor(255, 255, 255, math.min(((1 - (math.min(prc, .5) / .5)) + math.max(1 - (tick - p.lastHurt) * tickRate, 0) / 6) * 200, 200))
    love.graphics.draw(image, 0, 0, 0, love.graphics.width() / image:getWidth(), love.graphics.height() / image:getHeight())
  end
end
