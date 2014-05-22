HudHealth = class()

local g = love.graphics
local w, h = g.width, g.height

function HudHealth:init()
  local health = data.media.graphics.hud.health
  self.canvas = g.newCanvas(health:getWidth(), health:getHeight())
  self.val = 0
  self.prevVal = 0
end

function HudHealth:update()
  local p = ctx.players:get(ctx.id)
  if p then
    self.prevVal = self.val
    self.val = math.lerp(self.val, p.health, math.min(10 * tickRate, 1))
  end
end

function HudHealth:draw()
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
    love.graphics.translate(0, ctx.view.margin)
  end)
  
  if p then
    local s = w(.4775) / 382
    local x = w(.5) - (self.canvas:getWidth() * s * .5)
    g.setColor(255, 255, 255, 90)
    g.draw(self.canvas, x, 0, 0, s, s)
    g.setColor(255, 255, 255)
    g.draw(data.media.graphics.hud.health, x, 0, 0, s, s)
  end
end
