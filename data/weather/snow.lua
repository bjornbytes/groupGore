local Snow = {}
Snow.name = 'Snow'
Snow.code = 'snow'

function Snow:init()
  self.x = 0
  self.y = 0
  self.vx = 400 * (love.math.random() < .5 and -1 or 1)
  self.vy = 400 * (love.math.random() < .5 and -1 or 1)
  self.dx = love.math.random() < .5 and -1 or 1
  self.dy = love.math.random() < .5 and -1 or 1
  self.image = data.media.graphics.effects.bgBlizzard
  self.image:setWrap('repeat', 'repeat')
  self.depth = 1
  self.quad = love.graphics.newQuad(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), self.image:getWidth(), self.image:getHeight())
end

function Snow:update()
  self.x = self.x + self.vx * tickRate
  self.y = self.y + self.vy * tickRate
  self.vx = self.vx + self.dx * love.math.random(50, 100) * tickRate
  self.vy = self.vy + self.dy * love.math.random(50, 100) * tickRate
  if self.vx > 300 then self.dx = -1
  elseif self.vx < -300 then self.dx = 1 end
  if self.vy > 300 then self.dy = -1
  elseif self.vy < -300 then self.dy = 1 end
end

function Snow:gui()
  love.graphics.setColor(255, 255, 255, 90)
  local factor = 1
  local x, y = (ctx.view.x + ctx.view.w / 2 - self.x), (ctx.view.y + ctx.view.h / 2 - self.y)
  
  for _, z in ipairs({64, 128, 256}) do
    local scale = 1 + (ctx.view:convertZ(z) / 500)

    self.quad:setViewport(x, y, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.draw(self.image, self.quad, 0, 0, 0, scale, scale)
    factor = factor + .1
  end
end

return Snow
