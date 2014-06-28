MenuError = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuError:init()
  self.message = nil
  self.alpha = 0
  self.active = false
  self.timeout = 2
end

function MenuError:update()
  if not self.active then
    self.alpha = math.lerp(self.alpha, 0, 2 * tickRate)
    return
  end

  self.alpha = math.lerp(self.alpha, 1, 8 * tickRate)
  self.timeout = self.timeout - tickRate
  if self.timeout <= 0 then
    self.active = false
  end
end

function MenuError:draw()
  if self.alpha < .001 then return end
  
  local str = self.message
  g.setFont('pixel', 8)
  g.setColor(0, 0, 0, self.alpha * 255)
  g.rectangleCenter('fill', w(.5), h(.5), g.getFont():getWidth(str) + 16, g.getFont():getHeight() + 16)
  g.setColor(200, 50, 50, self.alpha * 255)
  g.rectangleCenter('line', w(.5), h(.5), g.getFont():getWidth(str) + 16, g.getFont():getHeight() + 16)
  g.printCenter(str, w(.5), h(.5))
end

function MenuError:activate(message)
  self.message = message
  self.active = true
  self.alpha = 0
  self.timeout = 2
end