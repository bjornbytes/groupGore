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
  
  map.walls = love.filesystem.load(dir .. 'walls.lua')(map)
  map.grass = love.graphics.newImage('/media/graphics/grass.png')
  for _, coords in pairs(map.walls) do
    ovw.collision:addWall(coords.x, coords.y, coords.w, coords.h)
  end

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
  
  love.graphics.setColor(0, 0, 0)
  for _, wall in pairs(self.walls) do
    love.graphics.rectangle('fill', wall.x, wall.y, wall.w, wall.h)
  end
  love.graphics.setColor(255, 255, 255)
end
