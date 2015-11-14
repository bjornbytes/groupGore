local Shell = {}

Shell.name = 'Shell'
Shell.code = 'shell'

Shell.activate = function(self)
  self.speed = love.math.random(250, 500)
  self.angularVelocity = love.math.random(-1, 1) * 2 * math.pi
  self.angle = love.math.random() * 2 * math.pi
  self.alpha = .8
  self.image = data.media.graphics.effects.shell
  self.scale = 1
  self.speedDecay = 5 + love.math.random() * 3
  self.depth = -2
  ctx.view:register(self)
end

Shell.update = function(self)
  self.angularVelocity = math.lerp(self.angularVelocity, 0, math.min(4 * tickRate, 1))
  self.angle = self.angle + self.angularVelocity * tickRate
  self.speed = math.lerp(self.speed, 0, math.min(self.speedDecay * tickRate, 1))
  self.x = self.x + math.dx(self.speed * tickRate, self.direction)
  self.y = self.y + math.dy(self.speed * tickRate, self.direction)
  if self.speed < .5 then
    self.alpha = math.lerp(self.alpha, 0, math.min(4 * tickRate, 1))
    if self.alpha < .01 then
      return true
    end
  end
end

Shell.draw = function(self)
  love.graphics.setColor(255, 255, 255, self.alpha * 255)
  love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Shell
