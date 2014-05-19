MenuBackground = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuBackground:init()
  self.mesh = love.graphics.newMesh({
    {0, 0, 0, 0},
    {800, 0, 1, 0},
    {800, 600, 1, 1},
    {0, 600, 0, 1}
  })

  self.mesh:setVertexColors(true)

  self.blend = {}
  self.blendSign = {}
  self.brightness = {}
  self.brightnessSign = {}

  for i = 1, 4 do
    self.brightness[i] = love.math.random() < .5 and .25 or .75
    self.brightnessSign[i] = love.math.random() < .5 and 1 or -1
    self.blend[i] = love.math.random() < .5 and .25 or .75
    self.blendSign[i] = love.math.random() < .5 and .25 or .75
  end
end

function MenuBackground:draw()
  for i = 1, 4 do
    self.brightness[i] = self.brightness[i] + self.brightnessSign[i] / love.math.random(21, 27) * delta
    if self.brightness[i] < 0 or self.brightness[i] > 1 then
      self.brightnessSign[i] = self.brightnessSign[i] * -1
    end

    self.blend[i] = self.blend[i] + self.blendSign[i] / love.math.random(13, 21) * delta
    if self.blend[i] < 0 or self.blend[i] > 1 then
      self.blendSign[i] = self.blendSign[i] * -1
    end
  end

  local purple, orange = {190, 160, 220, 60}, {240, 160, 140, 60}

  local c = {}
  for i = 1, 4 do
    c[i] = table.interpolate(purple, orange, self.blend[i])
    c[i] = table.interpolate({0, 0, 0, 60}, c[i], self.brightness[i])
    local x, y, u, v = self.mesh:getVertex(i)
    self.mesh:setVertex(i, x, y, u, v, unpack(c[i]))
  end
  
  g.reset()
  g.draw(data.media.graphics.menu.ggbg, 0, 0)
  g.setColor(255, 255, 255, 50)
  g.draw(self.mesh, 0, 0)

  g.setFont('BebasNeue', h(.1))
  g.setColor(50, 50, 50)
  g.print('group', w(.6), h(.1) - g.getFont():getHeight() / 2)
  g.setColor(160, 160, 160)
  g.print('Gore', w(.6) + g.getFont():getWidth('group'), h(.1) - g.getFont():getHeight() / 2)
  
  g.setColor(0, 0, 0, 80)
  g.rectangle('fill', 0, h(.2), w(), h(.1))
  g.rectangle('fill', 0, h(.8), w(), h(.2))
end
