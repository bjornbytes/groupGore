local ShadowDash = {}

ShadowDash.name = 'Shadow Dash'
ShadowDash.code = 'shadowdash'
ShadowDash.text = 'Shadow Dash'
ShadowDash.type = 'skill'

ShadowDash.cooldown = 5

function ShadowDash:activate(shadowDash)
  shadowDash.timer = 0
end

function ShadowDash:update(shadowDash)
  shadowDash.timer = timer.rot(shadowDash.timer)
end

function ShadowDash:canFire(shadowDash)
  return shadowDash.timer == 0
end

function ShadowDash:fire(shadowDash)
  ovw.spells:activate(self.id, data.spell.shadowdash)
  shadowDash.timer = shadowDash.cooldown
end

function ShadowDash:value(shadowDash)
  return shadowDash.timer / shadowDash.cooldown
end

function ShadowDash:draw(shadowDash)
  love.graphics.setColor(255, 255, 255, 100)
  love.graphics.draw(self.class.sprite, self.x + math.dx(data.spell.shadowdash.distance, self.angle), self.y + math.dy(data.spell.shadowdash.distance, self.angle), self.angle, 1, 1, self.class.anchorx, self.class.anchory)
end

return ShadowDash