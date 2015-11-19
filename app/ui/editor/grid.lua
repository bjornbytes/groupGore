local Grid = class()
Grid.name = 'Grid'

local g = love.graphics

function Grid:init()
  self.color = {0, 0, 0, 50}
  self.hoverColor = {0, 0, 0, 20}
  self.size = 32
  self.depth = -10000
end

function Grid:draw()
  g.setLineWidth(1 / ctx.view.scale)

  g.setColor(self.hoverColor)
  local x = math.floor(ctx.view:worldMouseX() / self.size) * self.size
  local y = math.floor(ctx.view:worldMouseY() / self.size) * self.size
  if x >= 0 and y >= 0 and x < ctx.map.width and y < ctx.map.height then
    g.rectangle('fill', x, y, self.size, self.size)
  end

  g.setColor(self.color)

  for i = .5, ctx.map.width + .5, self.size do
    g.line(i, 0, i, ctx.map.height)
  end

  for i = .5, ctx.map.height + .5, self.size do
    g.line(0, i, ctx.map.width, i)
  end
  g.setLineWidth(1)
end

function Grid:keypressed(key)
  if key == '[' then self.size = math.max(self.size / 2, 8)
  elseif key == ']' then self.size = math.min(self.size * 2, 256) end
end

function Grid:snap(x, y)
  if love.keyboard.isDown('lalt') then return x, y end
  return math.round(x / self.size) * self.size, math.round(y / self.size) * self.size
end

return Grid
