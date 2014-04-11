local ShadowDash = {}

ShadowDash.name = 'Shadow Dash'
ShadowDash.code = 'shadowdash'
ShadowDash.text = 'Shadow Dash'
ShadowDash.type = 'skill'

ShadowDash.cooldown = 5

function ShadowDash:activate(shadowDash)
  shadowDash.timer = 0
  shadowDash.reuse = 0
end

function ShadowDash:update(shadowDash)
  shadowDash.timer = timer.rot(shadowDash.timer)
  shadowDash.reuse = timer.rot(shadowDash.reuse, function()
    shadowDash.timer = shadowDash.cooldown
  end)
end

function ShadowDash:canFire(shadowDash)
  return shadowDash.timer == 0
end

function ShadowDash:fire(shadowDash)
  ovw.spells:activate(self.id, data.spell.shadowdash)
  if shadowDash.reuse == 0 then
    shadowDash.timer = .5
    shadowDash.reuse = 2.5
  else
    shadowDash.timer = shadowDash.cooldown
    shadowDash.reuse = 0
  end
end

function ShadowDash:value(shadowDash)
  if shadowDash.timer ~= 0 then
    if shadowDash.reuse ~= 0 then return shadowDash.timer / .5 end
    return shadowDash.timer / shadowDash.cooldown
  else
    return shadowDash.reuse / 2
  end
end

function ShadowDash:draw(shadowDash)
  love.graphics.setColor(255, 255, 255, 100)
  love.graphics.draw(self.class.sprite, self.x + math.dx(data.spell.shadowdash.distance, self.angle), self.y + math.dy(data.spell.shadowdash.distance, self.angle), self.angle, 1, 1, self.class.anchorx, self.class.anchory)
end

return ShadowDash