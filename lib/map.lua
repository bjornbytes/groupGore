Map = class()

function Map:init(name)
  name = 'jungleCarnage'

  local dir = 'maps/' .. name .. '/'
  local map  = love.filesystem.load(dir .. name .. '.lua')()
  map.graphics = {}
  
  for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
    if file:match('%.png$') then
      local image = file:gsub('%.png$', '')
      map.graphics[image] = love.graphics.newImage(dir .. file)
    end
  end

  table.merge(map, self)

  self.props = table.map(map.props, function(prop)
    setmetatable(prop, {__index = data.prop[prop.kind]})
    f.exe(prop.activate, prop, self)
    if ovw.view then ovw.view:register(prop) end
    return prop
  end)

  table.each(map.on, function(f, e)
    if ovw.event then ovw.event:on(e, self, f) end
  end)

  self.canvas = love.graphics.newCanvas(300, 300)

  self.points = {}
  self.points[purple] = 0
  self.points[orange] = 0
  self.pointLimit = 5

  f.exe(self.activate, self)

  self:score()

  self.depth = 5
  if ovw.view then ovw.view:register(self) end
end

function Map:update()
  table.each(self.props, function(p) f.exe(p.update, p) end)
end

function Map:draw()
  love.graphics.reset()
  
  for i = 0, self.width, self.graphics.background:getWidth() do
    for j = 0, self.height, self.graphics.background:getHeight() do
      love.graphics.draw(self.graphics.background, i, j)
    end
  end
end

function Map:hud()
  local s = (love.window.getHeight() * .1) / self.canvas:getWidth()
  local x = love.window:getWidth() / 2 - (self.canvas:getWidth() / 2 * s)
  love.graphics.draw(self.canvas, x, love.window.getHeight() * .01, 0, s, s)
  love.graphics.setColor(255, 255, 255)
  local w2 = (self.canvas:getWidth() / 2)
  w2 = (w2 - (w2 * .3)) * s
  x = love.window.getWidth() / 2
  local y = love.window.getHeight() * .01 + (self.canvas:getHeight() * s / 2) - (love.graphics.getFont():getHeight('M') / 2)
  love.graphics.printf(self.points[purple], x - (w2 * .75), y, w2 * .75, 'left')
  love.graphics.printf(self.points[orange], x, y, w2 * .75, 'right')
end

function Map:score(team)
  if team then self.points[team] = self.points[team] + 1 end
  self.canvas:clear()
  self.canvas:renderTo(function()
    love.graphics.setColor(190, 160, 220)
    local w2 = self.canvas:getWidth() / 2
    love.graphics.arc('fill', w2, w2, w2 - 1, math.pi * 0.5, math.pi * 1.5)
    love.graphics.setColor(240, 160, 140)
    love.graphics.arc('fill', w2, w2, w2 - 1, math.pi * 1.5, math.pi * 2.5)
    love.graphics.setBlendMode('subtractive')
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', w2, w2, w2 - (w2 * .3))
    love.graphics.arc('fill', w2, w2, w2, (math.pi * 0.5) + (math.pi * (self.points[purple] / self.pointLimit)), math.pi * 1.5)
    love.graphics.arc('fill', w2, w2, w2, math.pi * 1.5, (math.pi * 2.5) - (math.pi * (self.points[orange] / self.pointLimit)))
    love.graphics.setBlendMode('alpha')
  end)
end