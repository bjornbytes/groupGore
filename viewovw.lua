View = {}

function mouseX()
  return math.floor(((love.mouse.getX() / View.scale) + View.x) + .5)
end

function mouseY()
  return math.floor(((love.mouse.getY() / View.scale) + View.y) + .5)
end

function View:init()
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) return a.width > b.width end)
  while modes[#modes].width ~= modes[1].width do table.remove(modes, #modes) end
  table.sort(modes, function(a, b) return a.width * a.height > b.width * b.height end)
  love.window.setMode(modes[1].width, modes[1].height, {fullscreen = true, borderless = true})
  
  self.x = 0
  self.prevx = 0
  self.y = 0
  self.prevy = 0
  self.w = 800
  self.h = 600
  self.scale = love.window.getWidth() / self.w
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  local object = Players:get(myId)
  if object and not object.ded then
    self.x = math.lerp(self.x, ((object.x + object.x--[[mouseX()]]) / 2) - (self.w / 2), .25)
    self.y = math.lerp(self.y, ((object.y + object.y--[[mouseY()]]) / 2) - (self.h / 2), .25)
    if object.x - self.x > (self.w * .80) then self.x = object.x - (self.w * .80) end
    if object.y - self.y > (self.h * .80) then self.y = object.y - (self.h * .80) end
    if (self.x + self.w) - object.x > (self.w * .80) then self.x = object.x + (self.w * .80) - self.w end
    if (self.y + self.h) - object.y > (self.h * .80) then self.y = object.y + (self.h * .80) - self.h end
  end
  
  if self.x < 0 then self.x = 0 end
  if self.y < 0 then self.y = 0 end
  if self.x + self.w > map.width then self.x = map.width - self.w end
  if self.y + self.h > map.height then self.y = map.height - self.h end
end

function View:push(map, entities, t)
  love.graphics.push()
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  love.graphics.scale(View.scale)
  love.graphics.translate(-math.floor(x + .5), -math.floor(y + .5))
end

function View:pop()
  love.graphics.pop()
end

function View.resize()
  View.scale = love.window.getWidth() / View.w
end