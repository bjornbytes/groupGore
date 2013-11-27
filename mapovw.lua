Map = {}

function Map:load(name)
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
    CollisionOvw:addWall(coords.x, coords.y, coords.w, coords.h)
  end
  
  _G['map'] = map
end

function Map:update()
  if not map then return end
  
  View:update()
end

function Map:draw()
  if not map then return end
  
  love.graphics.reset()
  
  for i = 0, map.width, map.graphics.background:getWidth() do
    for j = 0, map.height, map.graphics.background:getHeight() do
      love.graphics.draw(map.graphics.background, i, j)
    end
  end
  
  love.graphics.setColor(0, 0, 0)
  for _, wall in pairs(map.walls) do
    love.graphics.rectangle('fill', wall.x, wall.y, wall.w, wall.h)
  end
  love.graphics.setColor(255, 255, 255)
end
