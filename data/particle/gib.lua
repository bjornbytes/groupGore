local Gib = {}

Gib.name = 'Gib'
Gib.code = 'gib'

Gib.images = {}

function Gib:activate()
  self.speed = love.math.random(250, 750)
  self.angularVelocity = love.math.random(-400, 400)
  self.angle = love.math.random() * math.pi * 2
  self.alpha = 1
  local i = 1 + love.math.random(6)
  Gib.images[i] = Gib.images[i] or love.graphics.newImage('media/graphics/effects/gib' .. i .. '.png')
  self.image = Gib.images[i]
end

function Gib:update()
  self.angularVelocity = math.lerp(self.angularVelocity, 0, tickRate * 20)
  self.angle = self.angle + self.angularVelocity * tickRate
  self.speed = self.speed - math.min(1200 * tickRate, self.speed)
  self.x = self.x + math.dx(self.speed * tickRate, self.angle)
  self.y = self.y + math.dy(self.speed * tickRate, self.angle)
  if self.speed == 0 then
    self.alpha = self.alpha - tickRate
    if self.alpha <= 0 then return true end
  end
end

function Gib:draw()
  love.graphics.setColor(255, 255, 255, self.alpha * 255)
  local w, h = self.image:getWidth(), self.image:getHeight()
  love.graphics.draw(self.image, self.x, self.y, self.angle, 1.1, 1.1, w / 2, h / 2)
end

return Gib