MenuBackground = class()

local g = love.graphics

function MenuBackground:init()
	self.bg = love.graphics.newImage('media/graphics/menu/ggbg.png')
  self.font = love.graphics.newFont('media/fonts/BebasNeue.ttf', h(.1))
end

function MenuBackground:draw()
  g.reset()
	g.draw(self.bg, 0, 0)
  
  g.setFont(self.font)
  g.setColor(50, 50, 50)
  g.print('group', w(.6), h(.1) - g.getFont():getHeight() / 2)
  g.setColor(160, 160, 160)
  g.print('Gore', w(.6) + g.getFont():getWidth('group'), h(.1) - g.getFont():getHeight() / 2)
  
  g.setColor(0, 0, 0, 80)
  g.rectangle('fill', 0, h(.2), w(), h(.1))
  g.rectangle('fill', 0, h(.8), w(), h(.2))
end