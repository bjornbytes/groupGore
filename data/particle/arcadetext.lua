local ArcadeText = {}

ArcadeText.name = 'ArcadeText'
ArcadeText.code = 'arcadetext'

ArcadeText.activate = function(self)
  local dir = math.clamp(love.math.randomNormal(math.pi / 6, math.pi / 2), math.pi / 3, 2 * math.pi / 3)
  self.vx = math.cos(dir) * 100
  self.vy = math.sin(dir) * -100
  self.alpha = 1.5
  ctx.view:register(self, 'gui')
end

ArcadeText.update = function(self)
  self.prevx, self.prevy = self.x, self.y
  self.x = self.x + self.vx * tickRate
  self.y = self.y + self.vy * tickRate
  self.vy = self.vy + 500 * tickRate
  self.alpha = math.lerp(self.alpha, 0, math.min(4 * tickRate, 1))
  if self.alpha < .01 then return true end
end

ArcadeText.gui = function(self)
  local g, v = love.graphics, ctx.view
  local a = math.min(self.alpha, 1)
  local x = math.lerp(self.prevx or self.x, self.x, tickDelta / tickRate)
  local y = math.lerp(self.prevy or self.y, self.y, tickDelta / tickRate)
  x = (x - v.x) * v.scale
  y = (y - v.y) * v.scale
  g.setFont('pixel', 8)
  g.setColor(0, 0, 0, 255 * a)
  g.printCenter(self.str, x + 1, y + 1)
  g.setColor(255, 255, 255, 255 * a)
  g.printCenter(self.str, x, y)
end

return ArcadeText