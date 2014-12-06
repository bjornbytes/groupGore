MenuAlert = class()

local g = love.graphics

function MenuAlert:init()
  self.message = nil
  self.alpha = 0
end

function MenuAlert:update()
  self.alpha = math.max(self.alpha - tickRate, 0)
end

function MenuAlert:draw()
  if self.alpha < .001 then return end
  local u, v = ctx.u, ctx.v

  local str = self.message
  g.setFont('pixel', 8)
  local font = g.getFont()
  local w, h = font:getWidth(str), font:getHeight()
  g.setColor(0, 0, 0, math.min(self.alpha, 1) * 255)
  g.rectangleCenter('fill', .5 * u, .5 * v, w + 16, h + 16)
  g.setColor(255, 255, 255, math.min(self.alpha, 1) * 255)
  g.rectangleCenter('line', .5 * u, .5 * v, w + 16, h + 16, true, true, true)
  g.printCenter(str, .5 * u, .5 * v)
end

function MenuAlert:show(message, alpha)
  alpha = alpha or 2
  self.alpha = alpha
  self.message = message
end
