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

  map.props = table.map(map.props, function(prop)
    setmetatable(prop, {__index = data.prop[prop.kind]})
    f.exe(prop.activate, prop)
    return prop
  end)
  
  table.merge(map, self)
end

function Map:update()
  --
end

function Map:draw()
  love.graphics.reset()
  
  for i = 0, self.width, self.graphics.background:getWidth() do
    for j = 0, self.height, self.graphics.background:getHeight() do
      love.graphics.draw(self.graphics.background, i, j)
    end
  end

  table.with(self.props, f.ego('draw'))
end
