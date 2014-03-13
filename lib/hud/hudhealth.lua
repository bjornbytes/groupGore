HudHealth = class()

local g = love.graphics

function HudHealth:init()
  self.canvas = g.newCanvas(160, 160)
  self.back = g.newImage('media/graphics/healthBack.png')
  self.glass = g.newImage('media/graphics/healthGlass.png')
  self.red = g.newImage('media/graphics/healthRed.png')
  self.val = 0
  self.prevVal = 0
end

function HudHealth:update()
  local p = ovw.players:get(myId)
  if p and p.active then
    self.prevVal = self.val
    self.val = math.lerp(self.val, p.health, .25)
  end
end

function HudHealth:draw()
  local p = ovw.players:get(myId)
  self.canvas:clear()
  self.canvas:renderTo(function()
    g.setColor(255, 255, 255, 255)
    g.draw(self.red, 4, 13)
    g.setBlendMode('subtractive')
    g.setColor(255, 255, 255, 255)
    g.arc('fill', 80, 80, 80, 0, -((2 * math.pi) * (1 - (math.lerp(self.prevVal, self.val, tickDelta / tickRate) / p.maxHealth))))
    g.setBlendMode('alpha')
  end)
  
  if p and p.active then
    local s = math.min(1, h(.2) / 160)
    g.setColor(255, 255, 255)
    g.draw(self.back, 12 * s, 12 * s, 0, s, s)
    g.draw(self.canvas, 4 * s, 4 * s, 0, s, s)
    g.draw(self.glass, 0, 0, 0, s, s)
    g.printCenter(math.ceil(p.health), (4 * s) + (s * self.canvas:getWidth() / 2) - 3, (4 * s) + (s * self.canvas:getHeight() / 2))
  end
end