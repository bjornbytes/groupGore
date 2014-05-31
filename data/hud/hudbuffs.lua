HudBuffs = class()

local g = love.graphics
local w, h = love.graphics.width, love.graphics.height

function HudBuffs:draw()
  local p = ctx.players:get(ctx.id)
  if p then
    g.setColor(255, 255, 255)
    local xx = w(.01)
    table.each(ctx.buffs.buffs, function(b)
      if b.owner == p then
        g.rectangle('line', xx, h(.1), w(.02), w(.02))
        xx = xx + w(.025)
      end
    end)
  end
end