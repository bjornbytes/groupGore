local Dead = class()

function Dead:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)
  if p and p.ded then
    local val = math.ceil(math.max(p.ded, 0))
    love.graphics.setFont('BebasNeue', v * .08)
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.printCenter(val, u * .5 + 2, v * .5 + 2)
    love.graphics.setColor(255, 255, 255)
    love.graphics.printCenter(val, u * .5, v * .5)
  end
end

return Dead
