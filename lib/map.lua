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

  local dir = 'data/maps/' .. name .. '/'

  self.props = {}
  self.tiles = {}
  
  map = self
  table.merge(safeLoad(dir .. name .. '.lua'), self)
  local props = safeLoad(dir .. 'props.lua')
  local tiles = safeLoad(dir .. 'tiles.lua')
  map = nil

  table.merge(tiles, self.tiles)
  table.merge(props, self.props)
  self.props = table.map(self.props, function(prop)
    setmetatable(prop, {__index = data.prop[prop.kind], __tostring = data.prop[prop.kind].__tostring})
    f.exe(prop.activate, prop, self)
    return prop
  end)

  self.atlas = love.graphics.newImage(dir .. name .. '.png')
  self.batch = love.graphics.newSpriteBatch(self.atlas, #self.tiles + #self.props)

  self.textures = table.map(self.textures, function(tex)
    tex[5], tex[6] = self.atlas:getDimensions()
    return love.graphics.newQuad(unpack(tex))
  end)

  self.batch:bind()
  self.batch:setColor(255, 255, 255)
  table.each(self.tiles, function(tile)
    tile[1] = self.textures[tile[1]]
    self.batch:add(unpack(tile))
  end)
  self.batch:unbind()

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
  love.graphics.draw(self.batch)
end

function Map:score(team)
  if team then self.points[team] = self.points[team] + 1 end
end
