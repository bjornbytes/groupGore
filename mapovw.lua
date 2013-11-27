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
    coords.t = love.graphics.newMesh({
      {0, 0, 0, 0},
      {0, 0, 1, 0},
      {0, 0, 1, 1},
      {0, 0, 0, 1}
    }, map.grass)
    coords.s = love.graphics.newMesh({
      {0, 0, 0, 0},
      {0, 0, 1, 0},
      {coords.x, coords.y + coords.h, 1, 1},
      {coords.x + coords.w, coords.y + coords.h, 0, 1}
    }, map.grass)
  end
  
  _G['map'] = map
end


local function getz(z)
  return (.8 * z) ^ (1 + (.0008 * z))
end

local function getx(x)
  return (View.x + View.w / 2 - x) / 500
end

local function gety(y)
  return (View.y + View.h / 2 - y) / 500
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
  
  for _, wall in pairs(map.walls) do
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', wall.x, wall.y, wall.w, wall.h)
    
    local z = getz(64)
    wall.s:setVertex(1, wall.x - (z * getx(wall.x)), wall.y + wall.h - (z * gety(wall.y)), 0, 0)
    wall.s:setVertex(2, wall.x + wall.w - (z * getx(wall.x + wall.w)), wall.y + wall.h - (z * gety(wall.y + wall.h)), 1, 0)
    wall.s:setVertexMap(1, 2, 4, 3)
    wall.t:setVertex(1, wall.x - (z * getx(wall.x)), wall.y - (z * gety(wall.y)), 0, 0)
    wall.t:setVertex(2, wall.x + wall.w - (z * getx(wall.x + wall.w)), wall.y - (z * gety(wall.y)), 1, 0)
    wall.t:setVertex(3, wall.x + wall.w - (z * getx(wall.x + wall.w)), wall.y + wall.h - (z * gety(wall.y + wall.h)), 1, 1)
    wall.t:setVertex(4, wall.x - (z * getx(wall.x)), wall.y + wall.h - (z * gety(wall.y + wall.h)), 0, 1)
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(wall.s, 0, 0)
    love.graphics.draw(wall.t, 0, 0)
  end
end
