local Buffs = class()

local g = love.graphics

function Buffs:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)
  if p then
    g.setColor(255, 255, 255)
    local xx = u * .01
    table.each(ctx.buffs.buffs, function(b)
      if b.owner == p then
        g.rectangle('line', xx, v * .1, u * .02, u * .02)
        xx = xx + u * .025
      end
    end)
  end
end

return Buffs
