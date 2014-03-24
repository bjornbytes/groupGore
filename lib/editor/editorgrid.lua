EditorGrid = class()

local g = love.graphics

function EditorGrid:init()
  self.color = {0, 0, 0, 50}
  self.size = 32
  self.depth = -10000
end

function EditorGrid:draw()
  g.setColor(self.color)
  
  g.setLineWidth(1 / ovw.view.scale)
  for i = .5, ovw.map.width, self.size do
    g.line(i, 0, i, ovw.map.height)
  end
  
  for i = .5, ovw.map.height, self.size do
    g.line(0, i, ovw.map.width, i)
  end
end

function EditorGrid:keypressed(key)
  if key == '[' then self.size = math.max(self.size / 2, 8)
  elseif key == ']' then self.size = math.min(self.size * 2, 256) end
end

function EditorGrid:snap(x, y)
  if love.keyboard.isDown('lalt') then return x, y end
  return math.round(x / self.size) * self.size, math.round(y / self.size) * self.size
end