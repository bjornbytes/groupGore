local Map = class()

-- ...
purple = 0
orange = 1

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

  local function dir(x) return 'data/maps/' .. name .. '/' .. x end

  self.props = {}
  self.tiles = {}
  self.atlas = love.graphics.newImage(dir(name .. '.png'))

  table.merge(safeLoad(dir(name .. '.lua')), self)

  map = self
  local props = safeLoad(dir('props.lua'))
  local tiles = safeLoad(dir('tiles.lua'))
  map = nil

  table.merge(tiles, self.tiles)
  table.merge(props, self.props)

  self.textures = table.map(self.textures, function(tex)
    tex[5], tex[6] = self.atlas:getDimensions()
    return love.graphics.newQuad(unpack(tex))
  end)

  self.mods = {}
  table.each({{kind = 'scoring'}, {kind = 'deathmatch'}}, function(mod)
    setmetatable(mod, {__index = data.mods[mod.kind]})
    f.exe(mod.activate, mod, self)
    self.mods[mod.kind] = mod
  end)

  table.each(self.props, function(prop)
    setmetatable(prop, {
      __index = data.prop[prop.kind .. (ctx.tag or ''):capitalize()] or data.prop[prop.kind],
      __tostring = data.prop[prop.kind].__tostring
    })
  end)
  self.props = table.filter(self.props, function(prop) return not ctx.tag or not prop.mod or self.mods[prop.mod] end)
  table.each(self.props, function(prop, id)
    prop.id = id
    f.exe(prop.activate, prop, self)
  end)

  self.batch = love.graphics.newSpriteBatch(self.atlas, #self.tiles + #self.props)
  self.batch:bind()
  self.batch:setColor(255, 255, 255)
  table.each(self.tiles, function(tile)
    tile[1] = self.textures[tile[1]]
    self.batch:add(unpack(tile))
  end)
  self.batch:unbind()

  f.exe(self.activate, self)

  self.depth = 5
  if ctx.view then
    ctx.view:register(self)
    ctx.view.xmax = self.width
    ctx.view.ymax = self.height
  end

  if self.weather then
    self.weather = new(data.weather[self.weather])
    if ctx.view then
      ctx.view:register(self.weather, 'gui')
    end
  end

  if self.soundscape then
    ctx.event:emit('sound.loop', {sound = self.soundscape, gui = true})
  end

  if ctx.view and love.graphics.isSupported('shader') then
    local downsample = 4
    local working = love.graphics.newCanvas(self.width / downsample, self.height / downsample)
    self.shadows = love.graphics.newCanvas(self.width / downsample, self.height / downsample)
    self.shadows:renderTo(function()
      love.graphics.setColor(0, 0, 0)
      love.graphics.push()
      love.graphics.scale(1 / downsample)
      table.each(self.props, function(p)
        if p.code == 'wall' or p.code == 'crate' then
          p.shape:draw('fill')
        end
      end)
      love.graphics.pop()
    end)
    data.media.shaders.horizontalBlur:send('amount', .0008)
    data.media.shaders.verticalBlur:send('amount', .0008)
    love.graphics.setColor(255, 255, 255)
    for i = 1, 3 do
      love.graphics.setShader(data.media.shaders.horizontalBlur)
      working:renderTo(function()
        love.graphics.draw(self.shadows)
      end)
      love.graphics.setShader(data.media.shaders.verticalBlur)
      self.shadows:renderTo(function()
        love.graphics.draw(working)
      end)
    end
  end

  ctx.event:on(app.net.events.prop, function(data)
    local prop = self.props[data.id]
    prop.x, prop.y = data.x / 10, data.y / 10
  end)
end

function Map:update()
  table.each(self.props, function(p) f.exe(p.update, p) end)
  if self.weather then self.weather:update() end
  table.each(self.mods, function(mod) f.exe(mod.update, mod) end)
end

function Map:draw()
  love.graphics.draw(self.batch)
  love.graphics.draw(self.shadows, 0, 0, 0, 4, 4)
end

function Map:modExec(mod, fn, ...)
  local mod = self.mods[mod]
  if mod and mod[fn] then
    mod[fn](mod, ...)
  end
end

return Map
