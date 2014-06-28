MenuLoader = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuLoader:init()
  self.message = nil
  self.alpha = 0
  self.active = false
end

function MenuLoader:update()
  if not self.active then
    self.alpha = math.lerp(self.alpha, 0, 8 * tickRate)
    return
  end

  self.alpha = 1
end

function MenuLoader:draw()
  if self.alpha < .001 then return end
  
  local str = self.message .. '...'
  g.setFont('pixel', 8)
  g.setColor(0, 0, 0, self.alpha * 255)
  g.rectangleCenter('fill', w(.5), h(.5), g.getFont():getWidth(str) + 16, g.getFont():getHeight() + 16)
  g.setColor(255, 255, 255, self.alpha * 255)
  g.rectangleCenter('line', w(.5), h(.5), g.getFont():getWidth(str) + 16, g.getFont():getHeight() + 16)
  g.printCenter(str, w(.5), h(.5))
end

function MenuLoader:activate(message)
  self.message = message
  self.alpha = 0
  self.active = true
end

function MenuLoader:deactivate()
  self.active = false
end