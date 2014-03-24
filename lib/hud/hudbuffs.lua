HudBuffs = class()

local g = love.graphics
local w, h = love.graphics.width, love.graphics.height

function HudBuffs:draw()
  local p = ovw.players:get(myId)
  if p and p.active then
    g.setColor(255, 255, 255)
    local xx = h(.2) + h(.02)
    table.each(ovw.buffs.buffs, function(b)
      if b.target == p.id then
        g.rectangle('line', xx, h(.02), w(.02), w(.02))
        xx = xx + w(.025)
      end
    end)
  end
end