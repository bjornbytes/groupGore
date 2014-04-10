HudRight = class()

local g = love.graphics
local w, h = g.width, g.height

function HudRight:init()
  self.frame = g.newImage('media/graphics/hud/right.png')
  self.bg = g.newImage('media/graphics/hud/rightBg.png')
end

function HudRight:draw()
  g.setColor(255, 255, 255, 64)
  g.draw(self.bg, w(.81375), -h(.003))
  
  g.setColor(255, 255, 255, 255)
  g.draw(self.frame, w(.80375), -h(.01))
  
  local p = ovw.players:get(ovw.id)
  if p and p.active then
    g.setFont('BebasNeue', 5.2)
    
    if p.team == purple then love.graphics.setColor(190, 160, 220)
    else love.graphics.setColor(240, 160, 140) end
    g.print(tostring(ovw.map.points[p.team]), w(.85875), -h(.008))
    
    if p.team == purple then love.graphics.setColor(240, 160, 140)
    else love.graphics.setColor(190, 160, 220) end
    local str = tostring(ovw.map.points[1 - p.team])
    g.print(str, w(.95) - g.getFont():getWidth(str), -h(.008))
  end
end