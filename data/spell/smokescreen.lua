Smokescreen = {}

Smokescreen.code = 'smokescreen'
Smokescreen.duration = 6
Smokescreen.radius = 145
Smokescreen.image = data.media.graphics.effects.smoke

function Smokescreen:activate()
  self.timer = self.duration
  self.angle = love.math.random() * math.pi * 2
  self.x = self.owner.x
  self.y = self.owner.y
end

function Smokescreen:deactivate()
  ctx.players:each(function(p)
    if ctx.buffs:get(p, 'smokescreen') then ctx.buffs:remove(p, 'smokescreen') end
  end)
end

function Smokescreen:update()
  ctx.players:each(function(p)
    if p.team ~= self.owner.team and math.distance(self.x, self.y, p.x, p.y) < self.radius then
      if not ctx.buffs:get(p, 'smokescreen') then ctx.buffs:add(p, 'smokescreen') end
    else
      if ctx.buffs:get(p, 'smokescreen') then ctx.buffs:remove(p, 'smokescreen') end
    end
  end)
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
