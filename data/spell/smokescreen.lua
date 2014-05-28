local Smokescreen = {}

Smokescreen.code = 'smokescreen'
Smokescreen.duration = 6
Smokescreen.radius = 165
Smokescreen.image = data.media.graphics.effects.smoke

function Smokescreen:activate(mx, my)
  self.timer = Smokescreen.duration
  self.angle = love.math.random() * math.pi * 2
  self.x, self.y = mx, my
  ctx.event:emit('sound.play', {sound = 'smoke'})
end

function Smokescreen:update()
  if self.owner.cloak < 1 and math.distance(self.x, self.y, self.owner.x, self.owner.y) < self.radius then
    self.owner.cloak = math.min(self.owner.cloak + (3 * tickRate), 1)
  end

  self.timer = timer.rot(self.timer, function() ctx.spells:deactivate(self) end)
end

function Smokescreen:draw()
  local scale = self.radius / self.image:getWidth() * 2
  love.graphics.setColor(255, 255, 255, math.min(self.timer, 1) * .6 * 255)
  love.graphics.circle('line', self.x, self.y, self.radius)
  love.graphics.setColor(255, 255, 255, math.min(self.timer, 1) * .8 * 255)
  love.graphics.draw(self.image, self.x, self.y, self.angle, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Smokescreen
