HudHealth = class()

local g = love.graphics
local w, h = g.width, g.height

function HudHealth:init()
  self.canvas = g.newCanvas(160, 160)
  self.back = g.newImage('media/graphics/healthBack.png')
  self.glass = g.newImage('media/graphics/healthGlass.png')
  self.red = g.newImage('media/graphics/healthRed.png')
  self.val = 0
  self.prevVal = 0
  self.x = 0
  self.prevX = self.x
end

function HudHealth:update()
  local p = ovw.players:get(myId)
  if p and p.active then
    self.prevVal = self.val
    self.val = math.lerp(self.val, p.health, .25)

    self.prevX = self.x
    if p.class.secondary then
      self.x = math.lerp(self.x, w(.02), .2)
    else
      self.x = math.lerp(self.x, 0, .2)
    end
  end
end

function HudHealth:draw()
  local p = ovw.players:get(myId)
  self.canvas:clear()
  self.canvas:renderTo(function()
    g.pop()
    g.setColor(255, 255, 255, 255)
    g.draw(self.red, 4, 13)
    g.setBlendMode('subtractive')
    g.setColor(255, 255, 255, 255)
    g.arc('fill', 80, 80, 80, 0, -((2 * math.pi) * (1 - (math.lerp(self.prevVal, self.val, tickDelta / tickRate) / p.maxHealth))))
    g.setBlendMode('alpha')
    love.graphics.push()
    love.graphics.translate(0, ovw.view.margin)
  end)
  
  if p and p.active then
    local x = math.lerp(self.prevX, self.x, tickDelta / tickRate)
    local s = math.min(1, h(.2) / 160)
    g.setColor(255, 255, 255)
    g.draw(self.back, x + 12 * s, 12 * s, 0, s, s)
    g.draw(self.canvas, x + 4 * s, 4 * s, 0, s, s)
    g.draw(self.glass, x, 0, 0, s, s)
    g.setFont('aeromatics', 2)
    g.printCenter(math.ceil(p.health), x + (4 * s) + (s * self.canvas:getWidth() / 2) - 3, (4 * s) + (s * self.canvas:getHeight() / 2))
    if p.class.secondary then
      g.setColor(160, 160, 160, 100)
      g.rectangle('fill', 2, 2 + ((1 - p.class.secondary(p)) * (h(.2) - 4)), w(.02) - 4, p.class.secondary(p) * (h(.2) - 4))
      g.setColor(160, 160, 160)
      g.rectangle('line', 2, 2, w(.02) - 4, h(.2) - 4)
    end
  end
end