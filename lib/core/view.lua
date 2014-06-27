View = class()

function View:init()
  love.window.setMode(0, 0, {fullscreen = true})
  love.mouse.setGrabbed(true)

  self.x = 0
  self.y = 0
  self.width = 960
  self.height = 600
  self.xmin = 0
  self.ymin = 0
  self.xmax = self.width
  self.ymax = self.height

  self.frame = {}
  self.frame.x = 0
  self.frame.y = 0
  self.frame.width = love.window.getWidth()
  self.frame.height = love.window.getHeight()

  self.toDraw = {}
  self.target = nil

  self:resize()

  self.prevx = 0
  self.prevy = 0
  self.prevscale = self.scale
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale
  
  self:follow()
  self:contain()
end

function View:draw()
  love.graphics.push()
  love.graphics.translate(self.frame.x, self.frame.y)

  love.graphics.push()
  local x, y, s = unpack(table.interpolate({self.prevx, self.prevy, self.prevscale}, {self.x, self.y, self.scale}, tickDelta / tickRate))
  love.graphics.scale(s)
  love.graphics.translate(-x, -y)
  
  table.sort(self.toDraw, function(a, b)
    return a.depth > b.depth
  end)

  for _, v in ipairs(self.toDraw) do f.exe(v.draw, v) end

  love.graphics.pop()

  for _, v in ipairs(self.toDraw) do f.exe(v.gui, v) end
  
  local w, h = love.graphics.getDimensions()
  love.graphics.pop()

  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', 0, 0, w, self.frame.y)
  love.graphics.rectangle('fill', 0, 0, self.frame.x, h)
  love.graphics.rectangle('fill', 0, self.frame.y + self.frame.height, w, h - (self.frame.y + self.frame.height))
  love.graphics.rectangle('fill', self.frame.x + self.frame.width, 0, w - (self.frame.x + self.frame.width), h)
end

function View:resize()
  self.frame.x, self.frame.y = 0, 0
  self.frame.width, self.frame.height = self.width, self.height
  if (self.width / self.height) > (love.graphics.getWidth() / love.graphics.getHeight()) then
    self.margin = math.max(math.round(((love.graphics.getHeight() - love.graphics.getWidth() * (self.height / self.width)) / 2)), 0)
    self.scale = love.graphics.getWidth() / self.width
    local margin = math.max(math.round(((love.graphics.getHeight() - love.graphics.getWidth() * (self.height / self.width)) / 2)), 0)
    self.frame.y = margin
    self.frame.height = love.graphics.getHeight() - 2 * margin
    self.frame.width = love.graphics.width()
  else
    self.margin = math.max(math.round(((love.graphics.getWidth() - love.graphics.getHeight() * (self.width / self.height)) / 2)), 0)
    self.scale = love.graphics.getHeight() / self.height
    local margin = math.max(math.round(((love.graphics.getWidth() - love.graphics.getHeight() * (self.width / self.height)) / 2)), 0)
    self.frame.x = margin
    self.frame.width = love.graphics.getWidth() - 2 * margin
    self.frame.height = love.graphics.getHeight()
  end
end

function View:register(x)
  table.insert(self.toDraw, x)
  x.depth = x.depth or 0
end

function View:unregister(x)
  for i = 1, #self.toDraw do
    if self.toDraw[i] == x then table.remove(self.toDraw, i) return end
  end
end

function View:convertZ(z)
  return (.8 * z) ^ (1 + (.0008 * z))  
end

function View:three(x, y, z)
  z = self:convertZ(z)
  return x - (z * ((self.x + self.width / 2 - x) / 500)), y - (z * ((self.y + self.height / 2 - y) / 500))
end

function View:contain()
  self.x = math.clamp(self.x, 0, self.xmax - self.width)
  self.y = math.clamp(self.y, 0, self.ymax - self.height)
end

function View:follow()
  if not self.target then return end

  local dis, dir = math.vector(self.target.x, self.target.y, self:worldMouseX(), self:worldMouseY())
  local margin = 0.8
  
  dis = 0--dis / 10
 
  self.x = self.target.x + math.dx(dis, dir) - (self.width / 2)
  self.y = self.target.y + math.dy(dis, dir) - (self.height / 2)
  
  self.x = math.clamp(self.x, self.target.x - (self.width * margin), self.target.x + (self.width * margin) - self.width)
  self.y = math.clamp(self.y, self.target.y - (self.height * margin), self.target.y + (self.height * margin) - self.height)
end

function View:worldMouseX()
  return math.round(((love.mouse.getX() - self.frame.x) / self.scale) + self.x)
end

function View:worldMouseY()
  return math.round(((love.mouse.getY() - self.frame.y) / self.scale) + self.y)
end

function View:frameMouseX()
  return love.mouse.getX() - self.frame.x
end

function View:frameMouseY()
  return love.mouse.getY() - self.frame.y
end