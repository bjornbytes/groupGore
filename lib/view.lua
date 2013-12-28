View = class()

function mouseX()
  return math.floor(((love.mouse.getX() / ovw.view.scale) + ovw.view.x) + .5)
end

function mouseY()
  return math.floor((((love.mouse.getY() - ovw.view.margin) / ovw.view.scale) + ovw.view.y) + .5)
end

function View:init()
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) return a.width > b.width end)
  while modes[#modes].width ~= modes[1].width do table.remove(modes, #modes) end
  table.sort(modes, function(a, b) return a.width * a.height > b.width * b.height end)
  love.window.setMode(modes[1].width, modes[1].height, {fullscreen = true, borderless = true, vsync = true})
  -- love.window.setMode(640, 480, {fullscreen = false, borderless = false, vsync = true})
  
  self.x = 0
  self.prevx = 0
  self.y = 0
  self.prevy = 0
  self.w = 800
  self.h = 450
  self.scale = love.window.getWidth() / self.w
  self.margin = math.floor(((love.window.getHeight() - love.window.getWidth() * (self.h / self.w)) / 2) + .5)
  self.toDraw = {}
end

function View:register(x)
  table.insert(self.toDraw, x)
end

function View:unregister(x)
  self.toDraw = table.filter(self.toDraw, function(v) return v ~= x end)
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  local object = ovw.players:get(myId)
  if object and not object.ded then
    local dis, dir = math.distance(object.x, object.y, mouseX(), mouseY()), math.direction(object.x, object.y, mouseX(), mouseY()) + math.pi / 2
    dis = dis / 4
    self.x = math.lerp(self.x, (object.x + math.cos(dir) * dis) - (self.w / 2), .5)
    self.y = math.lerp(self.y, (object.y + math.sin(dir) * dis) - (self.h / 2), .5)
    if object.x - self.x > (self.w * .80) then self.x = object.x - (self.w * .80) end
    if object.y - self.y > (self.h * .80) then self.y = object.y - (self.h * .80) end
    if (self.x + self.w) - object.x > (self.w * .80) then self.x = object.x + (self.w * .80) - self.w end
    if (self.y + self.h) - object.y > (self.h * .80) then self.y = object.y + (self.h * .80) - self.h end
  end
  
  if self.x < 0 then self.x = 0 end
  if self.y < 0 then self.y = 0 end
  if self.x + self.w > ovw.map.width then self.x = ovw.map.width - self.w end
  if self.y + self.h > ovw.map.height then self.y = ovw.map.height - self.h end
end

function View:push()
  love.graphics.push()
  love.graphics.translate(0, self.margin)
  love.graphics.push()
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  love.graphics.scale(self.scale)
  love.graphics.translate(-math.floor(x + .5), -math.floor(y + .5))
end


function View:draw()
  self:push()
  
  table.sort(self.toDraw, function(a, b)
    return a.depth > b.depth
  end)

  for k, v in ipairs(self.toDraw) do v:draw() end
  self:pop()
  ovw.hud:draw()
  self:letterbox()
end

function View:pop()
  love.graphics.pop()
end

function View:letterbox()
  love.graphics.pop()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), self.margin)
  love.graphics.rectangle('fill', 0, love.window.getHeight() - self.margin, love.window.getWidth(), self.margin)
end

function View:resize()
  self.scale = love.window.getWidth() / self.w
  self.margin = math.floor(((love.window.getHeight() - love.window.getWidth() * (self.h / self.w)) / 2) + .5)
end

function View:three(x, y, z)
  z = (.8 * z) ^ (1 + (.0008 * z))
  
  return x - (z * ((self.x + self.w / 2 - x) / 500)), y - (z * ((self.y + self.h / 2 - y) / 500))
end