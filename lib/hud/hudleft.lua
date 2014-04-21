HudLeft = class()

local g = love.graphics
local w, h = g.width, g.height

function HudLeft:init()
  self.frame = g.newImage('media/graphics/hud/left.png')
  self.bg = g.newImage('media/graphics/hud/leftBg.png')
end

function HudLeft:draw()
  g.setColor(255, 255, 255, 64)
  g.draw(self.bg, -w(.0825), -h(.0083))
  
  g.setColor(255, 255, 255)
  g.draw(self.frame, -w(.08), -h(.013))
  
  local p = ctx.players:get(ctx.id)
  if p and p.active then
    local clip = tostring(p.slots[p.input.weapon].currentClip)
    local ammo = tostring(p.slots[p.input.weapon].currentAmmo)
    
    g.setFont('BebasNeue', 6.5)
    local font = g:getFont()
    g.setColor(255, 255, 255)
    g.printCenter(clip .. ' /', w(.055), -h(.004), true, false)
    
    g.setFont('BebasNeue', 4.5)
    g.setColor(255, 255, 255, 153)
    g.printCenter(ammo, w(.0575) + (font:getWidth(clip .. ' /') / 2) + (g.getFont():getWidth(ammo) / 2), h(.015), true, false)
  end
end
