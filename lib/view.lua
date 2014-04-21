View = class()

function mouseX()
  return math.floor(((love.mouse.getX() / ovw.view.scale) + ovw.view.x) + .5)
end

function mouseY()
  return math.floor((((love.mouse.getY() - ovw.view.margin) / ovw.view.scale) + ovw.view.y) + .5)
end

function View:init()
  self.x = 0
  self.prevx = 0
  self.y = 0
  self.prevy = 0
  self.w = 800
  self.h = 600
  self.scale = love.graphics.getWidth() / self.w
  self.prevscale = self.scale
  self.margin = math.floor(((love.graphics.getHeight() - love.graphics.getWidth() * (self.h / self.w)) / 2) + .5)
  self.toDraw = {}
end

function View:register(x)
  table.insert(self.toDraw, x)
  x.depth = x.depth or 0
end

function View:unregister(x)
  for i = 1, #self.toDraw do
    if self.toDraw[i] == x then table.remove(self.toDraw, i) return end
  end
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale
  if ovw.players then
    local object = ovw.players:get(ovw.id)
    if object and not object.ded then
      local dis, dir = math.distance(object.x, object.y, mouseX(), mouseY()), math.direction(object.x, object.y, mouseX(), mouseY())
      dis = dis / 2
      self.x = object.x + (math.cos(dir) * dis) - (self.w / 2)
      self.y = object.y + (math.sin(dir) * dis) - (self.h / 2)
      local margin = 0.8
      if object.x - self.x > (self.w * margin) then self.x = object.x - (self.w * margin) end
      if object.y - self.y > (self.h * margin) then self.y = object.y - (self.h * margin) end
      if (self.x + self.w) - object.x > (self.w * margin) then self.x = object.x + (self.w * margin) - self.w end
      if (self.y + self.h) - object.y > (self.h * margin) then self.y = object.y + (self.h * margin) - self.h end
    end
  end
  
  self:contain()
end

function View:push()
  love.graphics.push()
  love.graphics.translate(0, self.margin)
  love.graphics.push()
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  love.graphics.scale(math.lerp(self.prevscale, self.scale, tickDelta / tickRate))
  love.graphics.translate(-x, -y)
end


function View:draw()
  self:push()
  
  table.sort(self.toDraw, function(a, b)
    return a.depth > b.depth
  end)

  for _, v in ipairs(self.toDraw) do f.exe(v.draw, v) end

  self:pop()

  for _, v in ipairs(self.toDraw) do f.exe(v.gui, v) end
  
  self:letterbox()
end

function View:pop()
  love.graphics.pop()
end

function View:letterbox()
  love.graphics.pop()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), self.margin)
  love.graphics.rectangle('fill', 0, love.graphics.getHeight() - self.margin, love.graphics.getWidth(), self.margin)
end

function View:resize()
  self.scale = love.graphics.getWidth() / self.w
  self.margin = math.max(math.round(((love.graphics.getHeight() - love.graphics.getWidth() * (self.h / self.w)) / 2)), 0)
end

function View:convertZ(z)
  return (.8 * z) ^ (1 + (.0008 * z))  
end

function View:three(x, y, z)
  z = self:convertZ(z)
  
  return x - (z * ((self.x + self.w / 2 - x) / 500)), y - (z * ((self.y + self.h / 2 - y) / 500))
end

function View:contain()
  if self.x < 0 then self.x = 0 end
  if self.y < 0 then self.y = 0 end
  if self.x + self.w > ovw.map.width then self.x = ovw.map.width - self.w end
  if self.y + self.h > ovw.map.height then self.y = ovw.map.height - self.h end
end
