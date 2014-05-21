HudLeft = class()

local g = love.graphics
local w, h = g.width, g.height

function HudLeft:draw()
  g.setColor(255, 255, 255, 64)
  g.draw(data.media.graphics.hud.leftBg, -w(.0825), -h(.0083))
  
  g.setColor(255, 255, 255)
  g.draw(data.media.graphics.hud.left, -w(.08), -h(.013))
  
  local p = ctx.players:get(ctx.id)
  if p and p.active then
    local clip = tostring(p.slots[p.weapon].currentClip)
    local ammo = tostring(p.slots[p.weapon].currentAmmo)
    
    g.setFont('BebasNeue', h(.065))
    local font = g:getFont()
    g.setColor(255, 255, 255)
    g.printCenter(clip .. ' /', w(.055), -h(.004), true, false)
    
    g.setFont('BebasNeue', h(.045))
    g.setColor(255, 255, 255, 153)
    g.printCenter(ammo, w(.0575) + (font:getWidth(clip .. ' /') / 2) + (g.getFont():getWidth(ammo) / 2), h(.015), true, false)
  end
end
