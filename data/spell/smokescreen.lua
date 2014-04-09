Smokescreen = {}

Smokescreen.code = 'smokescreen'
Smokescreen.duration = 6
Smokescreen.radius = 135
Smokescreen.image = love.graphics.newImage('media/graphics/effects/smoke.png')

function Smokescreen:activate()
  self.timer = self.duration
  self.angle = love.math.random() * math.pi * 2
  self.x = self.owner.input.mx
  self.y = self.owner.input.my
end

function Smokescreen:deactivate()
  ovw.players:with(ovw.players.active, function(p)
    if ovw.buffs:get(p, 'smokescreen') then ovw.buffs:remove(p, 'smokescreen') end
  end)
end

function Smokescreen:update()
  ovw.players:with(ovw.players.active, function(p)
    if p.team ~= self.owner.team and math.distance(self.x, self.y, p.x, p.y) < self.radius then
      if not ovw.buffs:get(p, 'smokescreen') then ovw.buffs:add(p, 'smokescreen') end
    else
      if ovw.buffs:get(p, 'smokescreen') then ovw.buffs:remove(p, 'smokescreen') end
    end
  end)
  self.timer = timer.rot(self.timer, function() ovw.spells:deactivate(self) end)
end

function Smokescreen:draw()
  local scale = self.radius / self.image:getWidth() * 2
  love.graphics.setColor(255, 255, 255, math.min(self.timer, 1) * .6 * 255)
  love.graphics.circle('line', self.x, self.y, self.radius)
  love.graphics.setColor(255, 255, 255, math.min(self.timer, 1) * .8 * 255)
  love.graphics.draw(self.image, self.x, self.y, self.angle, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Smokescreen