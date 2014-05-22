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
  name = 'industria'
  purple = 0
  orange = 1

  self.code = name

  local dir = 'data/maps/' .. name .. '/'
  local map = safeLoad(dir .. name .. '.lua')
  map.props = {}
  map.propsBy = {}
  
  table.merge(safeLoad(dir .. 'props.lua'), map.props)
  table.merge(map, self)
    
  self.props = table.map(map.props, f.cur(self.initProp, self))

  self.points = {}
  self.points[purple] = 0
  self.points[orange] = 0
  self.pointLimit = 5

  ctx.event:on(evtDead, function(data)
    local team = 1 - ctx.players:get(data.id).team
    self:score(team)
    if self.points[team] >= self.pointLimit then
      ctx.net:emit(evtChat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
      self.points[purple] = 0
      self.points[orange] = 0
    end
  end)

  f.exe(self.activate, self)

  self.depth = 5
  if ctx.view then
    ctx.view:register(self)
    ctx.view:setLimits(self.width, self.height)
  end
 
  if self.background then
    self.background:setWrap('repeat')
    self.backgroundMesh = love.graphics.newMesh({
      {0, 0, 0, 0},
      {self.width, 0, self.width / self.background:getWidth(), 0},
      {self.width, self.height, self.width / self.background:getWidth(), self.height / self.background:getHeight()},
      {0, self.height, self.height / self.background:getHeight(), 0}
    }, self.background)
  end
  
  if self.weather then
    self.weather = new(data.weather[self.weather])
    if ctx.view then
      ctx.view:register(self.weather)
    end
  end
end

function Map:update()
  table.each(self.props, function(p) f.exe(p.update, p) end)
  if self.weather then self.weather:update() end
end

function Map:draw()
  love.graphics.reset()
  if self.background then love.graphics.draw(self.backgroundMesh) end
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
