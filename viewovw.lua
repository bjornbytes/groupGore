View = {}

function mouseX()
  return love.mouse.getX() + math.floor(View.x + .5)
end

function mouseY()
  return love.mouse.getY() + math.floor(View.y + .5)
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  local object = Players:get(myId)
  if object then
    self.x = math.lerp(self.x, ((object.x + mouseX()) / 2) - (self.w / 2), .25)
    self.y = math.lerp(self.y, ((object.y + mouseY()) / 2) - (self.h / 2), .25)
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
  love.graphics.translate(-math.floor(x + .5), -math.floor(y + .5))
end

function View:pop()
  love.graphics.pop()
end

View.x = 0
View.prevx = 0
View.y = 0
View.prevy = 0
View.w = love.graphics.getWidth()
View.h = love.graphics.getHeight()