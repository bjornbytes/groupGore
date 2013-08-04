View = class()

function View:init(map)
  self.width = love.graphics.getWidth()
  self.height = love.graphics.getHeight()
  self.mapwidth = map.width
  self.mapheight = map.height
  
  self.x = 0
  self.y = 0
end

function View:mouseX()
  return love.mouse.getX() + math.floor(self.x + .5)
end

function View:mouseY()
  return love.mouse.getY() + math.floor(self.y + .5)
end

function View:update(object)
  if object then
    self.x = lerp(self.x, ((object.x + self:mouseX()) / 2) - (self.width / 2), .25)
    self.y = lerp(self.y, ((object.y + self:mouseY()) / 2) - (self.height / 2), .25)
    if object.x - self.x > (self.width * .80) then self.x = object.x - (self.width * .80) end
    if object.y - self.y > (self.height * .80) then self.y = object.y - (self.height * .80) end
    if (self.x + self.width) - object.x > (self.width * .80) then self.x = object.x + (self.width * .80) - self.width end
    if (self.y + self.height) - object.y > (self.height * .80) then self.y = object.y + (self.height * .80) - self.height end
  end
  
  if self.x < 0 then self.x = 0 end
  if self.y < 0 then self.y = 0 end
  if self.x + self.width > self.mapwidth then self.x = self.mapwidth - self.width end
  if self.y + self.height > self.mapheight then self.y = self.mapheight - self.height end
end

function View:draw(map, entities, t)
  love.graphics.push()
  love.graphics.translate(-math.floor(self.x + .5), -math.floor(self.y + .5))
  
  graphics.reset()
  map:draw()
  
  table.with(entities, function(e)
    graphics.reset()
    if e._name == 'Player' then
      if e.main then return e:draw(e:rewind(lerp(tick - 1, tick, tickDelta / tickRate))) end
      e:draw(e:rewind(t))
    else
      e:draw()
    end
  end)
  
  love.graphics.pop()
end

function View:cull()
  
end