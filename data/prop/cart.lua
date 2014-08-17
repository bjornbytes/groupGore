local Cart = class()
Cart.name = 'Cart'
Cart.code = 'cart'

Cart.mod = 'tugOfWar'

Cart.collision = {}
Cart.collision.shape = 'circle'
Cart.collision.tag = 'wall'

Cart.radius = 40
Cart.range = 120
Cart.speed = 30

Cart.depth = -5

function Cart:activate(map)
  ctx.event:emit('collision.attach', {object = self})
  if ctx.view then ctx.view:register(self) end

  self.prevX, self.prevY = self.x, self.y
  self.curves = table.map(self.curves, love.math.newBezierCurve)
end

function Cart:update()
  self.prevX, self.prevY = self.x, self.y
end

function Cart:draw()
  local g = love.graphics
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  g.setColor(255, 255, 255)
  table.each(self.curves, function(curve) g.line(curve:render()) end)
  g.setColor(255, 255, 255, 50)
  g.circle('fill', x, y, self.range)
  g.setColor(255, 255, 255, 100)
  g.circle('fill', x, y, self.radius)
  g.setColor(255, 255, 255)
  g.circle('line', x, y, self.radius)
end

return Cart