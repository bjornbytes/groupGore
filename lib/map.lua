Map = class()

local function safeLoad(file)
  local ok, chunk, result
  ok, chunk = pcall(love.filesystem.load, file)
  if not ok then print(chunk) return nil end
  
  ok, result = pcall(chunk)
  if not ok then print(result) return nil end
  
  return result
end

function Map:init(name)
  name = 'jungleCarnage'
  purple = 0
  orange = 1

  self.code = name

  local dir = 'maps/' .. name .. '/'
  local map = safeLoad(dir .. name .. '.lua')
  map.graphics = {}
  map.props = {}
  map.propsBy = {}
  
  for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
    if file:match('%.png$') then
      local image = file:gsub('%.png$', '')
      map.graphics[image] = love.graphics.newImage(dir .. file)
    end
  end
  
  table.merge(safeLoad(dir .. 'props.lua'), map.props)
  table.merge(map, self)
    
  self.props = table.map(map.props, f.cur(self.initProp, self))

  table.each(map.on, function(f, e)
    if ctx.event then
      ctx.event:on(e, function(data) f(self, data) end)
    end
  end)

  self.points = {}
  self.points[purple] = 0
  self.points[orange] = 0
  self.pointLimit = 5

  f.exe(self.activate, self)

  self:score()

  self.depth = 5
  if ctx.view then ctx.view:register(self) end
  
  self.graphics.background:setWrap('repeat')
  self.background = love.graphics.newMesh({
    {0, 0, 0, 0},
    {self.width, 0, self.width / self.graphics.background:getWidth(), 0},
    {self.width, self.height, self.width / self.graphics.background:getWidth(), self.height / self.graphics.background:getHeight()},
    {0, self.height, self.height / self.graphics.background:getHeight(), 0}
  }, self.graphics.background)
  
  if self.weather then
    self.weather = new(data.weather[self.weather])
    if ctx.view then ctx.view:register(self.weather) end
  end
end

function Map:update()
  table.each(self.props, function(p) f.exe(p.update, p) end)
  if self.weather then self.weather:update() end
end

function Map:draw()
  love.graphics.reset()
  love.graphics.draw(self.background)
end

function Map:score(team)
  if team then self.points[team] = self.points[team] + 1 end
end

function Map:initProp(prop)
  setmetatable(prop, {__index = data.prop[prop.kind], __tostring = data.prop[prop.kind].__tostring})
  f.exe(prop.activate, prop, self)
  self.propsBy[prop.kind] = self.propsBy[prop.kind] or {}
  table.insert(self.propsBy[prop.kind], prop)
  if ctx.view then ctx.view:register(prop) end
  return prop
end
