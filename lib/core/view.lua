View = class()

local g = love.graphics

function View:init()
  love.window.setMode(800, 600, {fullscreen = false, resizable = true, vsync = false})
  --love.mouse.setGrabbed(true)

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

  self.draws = {}
  self.guis = {}
  self.effects = {}
  self.target = nil

  self:resize()

  self.prevx = 0
  self.prevy = 0
  self.prevscale = self.scale

  self:register(data.media.shaders.motionBlur, 'shader')
  self:register(data.media.shaders.reddify, 'shader')
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale
  
  self:follow()
  self:contain()

  table.sort(self.draws, function(a, b)
    return a.depth > b.depth
  end)
end

function View:draw()
  local x, y, s = unpack(table.interpolate({self.prevx, self.prevy, self.prevscale}, {self.x, self.y, self.scale}, tickDelta / tickRate))
  local w, h = g.getDimensions()

  g.push()
  g.translate(self.frame.x, self.frame.y)
  g.scale(s)
  g.translate(-x, -y)

  self.canvas:clear()
  self.backCanvas:clear()
  self.canvas:renderTo(function()
    for i = 1, #self.draws do self.draws[i]:draw() end
  end)

  g.pop()

  for i = 1, #self.effects do
    g.setShader(self.effects[i].shader)
    g.setCanvas(self.backCanvas)
    g.draw(self.canvas)
    g.setCanvas()
    g.setShader()
    self.canvas, self.backCanvas = self.backCanvas, self.canvas
  end

  g.draw(self.canvas)

  g.push()
  g.translate(self.frame.x, self.frame.y)

  for i = 1, #self.guis do self.guis[i]:gui() end
  
  g.pop()

  g.setColor(0, 0, 0, 255)
  g.rectangle('fill', 0, 0, w, self.frame.y)
  g.rectangle('fill', 0, 0, self.frame.x, h)
  g.rectangle('fill', 0, self.frame.y + self.frame.height, w, h - (self.frame.y + self.frame.height))
  g.rectangle('fill', self.frame.x + self.frame.width, 0, w - (self.frame.x + self.frame.width), h)
end

function View:resize()
  local w, h = love.graphics.getDimensions()
  self.frame.x, self.frame.y, self.frame.width, self.frame.height = 0, 0, self.width, self.height
  if (self.width / self.height) > (w / h) then
    self.scale = w / self.width
    local margin = math.max(math.round(((h - w * (self.height / self.width)) / 2)), 0)
    self.frame.y = margin
    self.frame.height = h - 2 * margin
    self.frame.width = w
  else
    self.scale = h / self.height
    local margin = math.max(math.round(((w - h * (self.width / self.height)) / 2)), 0)
    self.frame.x = margin
    self.frame.width = w - 2 * margin
    self.frame.height = h
  end

  self.canvas = love.graphics.newCanvas(w, h, 'normal', 4)
  self.backCanvas = love.graphics.newCanvas(w, h, 'normal', 4)
end

function View:register(x, action)
  action = action or 'draw'
  if action == 'draw' then
    table.insert(self.draws, x)
    x.depth = x.depth or 0
  elseif action == 'gui' then
    table.insert(self.guis, x)
  elseif action == 'effect' then
    table.insert(self.effects, x)
  end
end

function View:unregister(x)
  if x.draw then
    for i = 1, #self.draws do
      if self.draws[i] == x then table.remove(self.draws, i) return end
    end
  end

  if x.gui then
    for i = 1, #self.guis do
      if self.guis[i] == x then table.remove(self.guis, i) return end
    end
  end

  for i = 1, #self.effects do
    if self.effects[i] == x then table.remove(self.effects, i) return end
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
  
  dis = dis / 2
 
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