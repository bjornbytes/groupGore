local StaticGrenade = {}

StaticGrenade.name = 'Static Grenade'
StaticGrenade.code = 'staticgrenade'
StaticGrenade.text = 'A grenade that slows and disarms.'
StaticGrenade.type = 'skill'

StaticGrenade.needsMouse = true
StaticGrenade.targeted = true
StaticGrenade.cooldown = 8

function StaticGrenade:activate(owner)
  self.timer = 0
  self.targetAlpha = 0
end

function StaticGrenade:update(owner)
  self.timer = timer.rot(self.timer)
  self.targetAlpha = math.lerp(self.targetAlpha, self.targeting and 1 or 0, math.min(10 * tickRate, 1))
end

function StaticGrenade:canFire(owner)
  return self.timer == 0
end

function StaticGrenade:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.staticgrenade, mx, my)
  self.timer = StaticGrenade.cooldown
  self.targetAlpha = 0
end

function StaticGrenade:gui(owner)
  if self.targetAlpha > 0 then
    local g, v = love.graphics, ctx.view
    g.setColor(255, 255, 255, self.targetAlpha * 255)
    g.circle('line', v:frameMouseX(), v:frameMouseY(), data.spell.staticgrenadeimpact.radius * v.scale, 100)
  end
end

function StaticGrenade:value(owner)
  return self.timer / self.cooldown
end

return StaticGrenade
