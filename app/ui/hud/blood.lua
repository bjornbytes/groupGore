local Blood = class()

function Blood:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)
  if p then
    local hp = math.lerp(ctx.hud.health.prevVal, ctx.hud.health.val, tickDelta / tickRate)
    local prc = hp / p.maxHealth
    local image = data.media.graphics.hud['hudBlood' .. 4 - math.floor(math.min(prc * 8, 3))]
    love.graphics.setColor(255, 255, 255, math.min(((1 - (math.min(prc, .5) / .5)) + math.max(1 - (tick - p.lastHurt) * tickRate, 0) / 6) * 200, 200))
    love.graphics.draw(image, 0, 0, 0, u / image:getWidth(), v / image:getHeight())
  end
end

return Blood
