local RocketBoots = {}

RocketBoots.name = 'Rocket Boots'
RocketBoots.code = 'rocketboots'
RocketBoots.text = 'Is that a rocket in your pocket?'
RocketBoots.type = 'skill'

RocketBoots.needsMouse = true
RocketBoots.cooldown = 12

function RocketBoots:activate(owner)
  self.timer = 0
end

function RocketBoots:update(owner)
  self.timer = timer.rot(self.timer)
end

function RocketBoots:canFire(owner)
  return self.timer == 0
end

function RocketBoots:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.rocketboots, mx, my)
  self.timer = self.cooldown
end

function RocketBoots:draw(owner)
  if owner.id == ctx.id then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(255, 255, 255, 30)
    love.graphics.circle('line', owner.x, owner.y, data.spell.rocketboots.maxDistance)
    love.graphics.setColor(r, g, b, a)
  end
end

function RocketBoots:value(owner)
  return self.timer / self.cooldown
end

return RocketBoots
