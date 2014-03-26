EditorMenu = class()

local g = love.graphics
local w, h = g.width, g.height

function EditorMenu:init()
  self.w = w(.2)
  self.h = h()
  self.x = -self.w
  self.y = 0
  
  self.active = false
end

function EditorMenu:update()
  if self.active then
    self.x = math.lerp(self.x, 0, tickRate * 20)
  else
    self.x = math.lerp(self.x, -self.w, tickRate * 20)
  end
end

function EditorMenu:draw()
  if math.round(self.x) > -self.w then
    g.setColor(10, 10, 10, 200)
    g.rectangle('fill', self.x, self.y, self.w, self.h)
  end
end

function EditorMenu:keypressed(key)
  if key == ' ' then
    self.active = not self.active
  end
end