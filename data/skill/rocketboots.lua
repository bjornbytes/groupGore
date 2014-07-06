local RocketBoots = {}

RocketBoots.name = 'Rocket Boots'
RocketBoots.code = 'rocketboots'
RocketBoots.text = 'Is that a rocket in your pocket?'
RocketBoots.type = 'skill'

RocketBoots.needsMouse = true
RocketBoots.targeted = true
RocketBoots.cooldown = 12

function RocketBoots:activate(owner)
  self.timer = 0
  self.targetAlpha = 0
end

function RocketBoots:update(owner)
  self.timer = timer.rot(self.timer)
  self.targetAlpha = math.lerp(self.targetAlpha, self.targeting and 1 or 0, math.min(10 * tickRate, 1))
end

function RocketBoots:canFire(owner)
  return self.timer == 0
end

function RocketBoots:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.rocketboots, mx, my)
  self.timer = self.cooldown
  self.targetAlpha = 0
end

function RocketBoots:gui(owner)
  if self.targetAlpha > .1 then
    local g, v = love.graphics, ctx.view
    g.pop()
    ctx.view:worldPush()
    g.setColor(255, 255, 255, self.targetAlpha * 255)
    g.circle('line', owner.drawX, owner.drawY, data.spell.rocketboots.maxDistance)
    g.pop()
    g.push()
    g.translate(v.frame.x, v.frame.y)
  end
end

function RocketBoots:value(owner)
  return self.timer / self.cooldown
end

return RocketBoots
