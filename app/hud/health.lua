Health = class()

local g = love.graphics

function Health:init()
  local health = data.media.graphics.hud.health
  self.canvas = g.newCanvas(health:getWidth(), health:getHeight())
  self.val = 0
  self.prevVal = 0
end

function Health:update()
  local p = ctx.players:get(ctx.id)
  if p then
    self.prevVal = self.val
    self.val = math.lerp(self.val, p.health, math.min(10 * tickRate, 1))
  end
end

function Health:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)

  self.canvas:clear()
  self.canvas:renderTo(function()
    g.pop()

    g.setColor(255, 255, 255)
    g.rectangle('fill', 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
    g.setBlendMode('subtractive')
    g.draw(data.media.graphics.hud.healthMask, 0, 0)
    local hp = math.lerp(self.prevVal, self.val, tickDelta / tickRate)
    local prc = hp / p.maxHealth
    local w = 366 - (prc * 366)
    g.rectangle('fill', 374 - w, 0, w, 51)
    g.setBlendMode('alpha')

    love.graphics.push()
    love.graphics.translate(ctx.view.frame.x, ctx.view.frame.y)
  end)

  if p then
    local s = u * .4775 / 382
    local x = u * .5 - (self.canvas:getWidth() * s * .5)
    g.setColor(255, 255, 255, 90)
    g.draw(self.canvas, x, 0, 0, s, s)
    g.setColor(255, 255, 255)
    g.draw(data.media.graphics.hud.health, x, 0, 0, s, s)
    g.setFont('BebasNeue', v * .04)
    g.setColor(100, 0, 0, 150)
    g.printCenter(math.ceil(p.health) .. ' / ' .. p.maxHealth, u * .5 + 2, data.media.graphics.hud.health:getHeight() * s / 2 + 2 + (v * .003))
    g.setColor(255, 255, 255, 255)
    g.printCenter(math.ceil(p.health) .. ' / ' .. p.maxHealth, u * .5, data.media.graphics.hud.health:getHeight() * s / 2 + (v * .003))
  end
end

return Health
