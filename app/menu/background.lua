local Background = class()

local g = love.graphics
local w, h = g.width, g.height

function Background:draw()
  g.setColor(255, 255, 255)
  g.draw(data.media.graphics.menu.ggbg, 0, 0)

  g.setFont('BebasNeue', h(.1))
  g.setColor(50, 50, 50)
  g.print('group', w(.6), h(.1) - g.getFont():getHeight() / 2)
  g.setColor(160, 160, 160)
  g.print('Gore', w(.6) + g.getFont():getWidth('group'), h(.1) - g.getFont():getHeight() / 2)

  g.setColor(0, 0, 0, 80)
  g.rectangle('fill', 0, h(.2), w(), h(.1))
end

return Background
