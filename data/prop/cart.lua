local Cart = class()
Cart.name = 'Cart'
Cart.code = 'cart'

Cart.collision = {}
Cart.collision.shape = 'circle'
Cart.collision.tag = 'wall'

Cart.radius = 40

Cart.depth = -5

function Cart:activate(map)
  ctx.event:emit('collision.attach', {object = self})
  if ctx.view then ctx.view:register(self) end

  self.curves = table.map(self.curves, love.math.newBezierCurve)
end

function Cart:update()
  --
end

function Cart:draw()
  local g = love.graphics
  g.setColor(255, 255, 255)
  table.each(self.curves, function(curve)
    g.line(curve:render(6))
  end)
  g.setColor(255, 255, 255, 100)
  g.circle('fill', self.x, self.y, self.radius)
  g.setColor(255, 255, 255)
  g.circle('line', self.x, self.y, self.radius)
end

return Cart