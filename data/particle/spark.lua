local Spark = {}

Spark.name = 'Spark'
Spark.code = 'spark'

Spark.activate = function(self)
  self.speed = love.math.random(200, 300)
  self.alpha = love.math.random(.6, 1)
  self.length = love.math.random(4, 12)
  self.angle = 0
end

Spark.update = function(self)
  self.alpha = self.alpha - 2 * tickRate
  if self.alpha <= 0 then return true end
  
  self.x = self.x + math.dx(self.speed * tickRate, self.angle)
  self.y = self.y + math.dy(self.speed * tickRate, self.angle)
end

Spark.draw = function(self)
  love.graphics.setColor(255, 255, 0, self.alpha * 255)
  love.graphics.setLineWidth(.5)
  love.graphics.line(self.x, self.y, self.x + math.dx(self.length, self.angle), self.y + math.dy(self.length, self.angle))
  love.graphics.setLineWidth(1)
end

return Spark