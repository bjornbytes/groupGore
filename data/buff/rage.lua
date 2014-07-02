local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.text = 'The brute has 20% additional lifesteal.'
Rage.hide = false


----------------
-- Data
----------------
function Rage:activate()
  self.owner.lifesteal = self.owner.lifesteal + .2
  if ctx.view then ctx.view:register(self) end
  self.alpha = 0
end

function Rage:update()
  self.alpha = math.lerp(self.alpha, 1, tickRate * 5)
end

function Rage:deactivate()
  self.owner.lifesteal = self.owner.lifesteal - .2
  if ctx.view then ctx.view:unregister(self) end
end

function Rage:draw()
  love.graphics.setColor(255, 0, 0, 100 * self.alpha * self.owner.alpha)
  local owner = self.owner
  local x, y, s = owner.drawX, owner.drawY, owner.drawScale * owner.class.scale * (1 + (.25 * self.alpha))
  love.graphics.draw(owner.class.sprite, x, y, owner.angle, s, s, owner.class.anchorx, owner.class.anchory)
end

return Rage
