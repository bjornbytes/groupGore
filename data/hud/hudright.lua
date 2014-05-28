HudRight = class()

local g = love.graphics
local w, h = g.width, g.height

function HudRight:draw()
  local s = ctx.view.scale

  g.setColor(255, 255, 255, 64)
  g.draw(data.media.graphics.hud.rightBg, w(.81375), -h(.003), 0, s, s)
  
  g.setColor(255, 255, 255, 255)
  g.draw(data.media.graphics.hud.right, w(.80375), -h(.01), 0, s, s)
  
  local p = ctx.players:get(ctx.id)
  if p then
    g.setFont('BebasNeue', h(.052))
    
    if p.team == purple then love.graphics.setColor(190, 160, 220)
    else love.graphics.setColor(240, 160, 140) end
    g.print(tostring(ctx.map.points[p.team]), w(.85875), -h(.008))
    
    if p.team == purple then love.graphics.setColor(240, 160, 140)
    else love.graphics.setColor(190, 160, 220) end
    local str = tostring(ctx.map.points[1 - p.team])
    g.print(str, w(.95) - g.getFont():getWidth(str), -h(.008))
  end
end
