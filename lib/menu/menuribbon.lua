MenuRibbon = class()

local g = love.graphics
local w, h = g.width, g.height

function MenuRibbon:init()
  self.ribbons = {0, 0, 0, 0, 0}
  self.count = 3
  self.fh = love.graphics.newFont('media/fonts/BebasNeue.ttf', h(.065)):getHeight() / 2
  self.margin = h(.1)
end

function MenuRibbon:test(x, y)
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  
  for i = 1, self.count do
    local yy = anchor - (self.margin * math.floor(self.count / 2)) + (self.margin * (i - 1)) - self.fh
    if math.inside(x, y, 0, yy, w(), self.fh * 2) then return i end
  end
  
  return nil
end

function MenuRibbon:draw()
  local anchor = h(.3) + (h(.8) - h(.3)) / 2
  
  local test = self:test(love.mouse.getPosition())
  for i = 1, self.count do
    if test == i then
      self.ribbons[i] = math.lerp(self.ribbons[i], 1, 20 * delta)
    else
      self.ribbons[i] = math.lerp(self.ribbons[i], 0, 30 * delta)
    end

    local ht = math.ceil(self.fh * 2 * self.ribbons[i])

    g.setColor(0, 0, 0, 80 * self.ribbons[i])
    g.rectangle('fill', 0, anchor - (self.margin * math.floor(self.count / 2)) + (self.margin * (i - 1)) - math.round(self.fh * self.ribbons[i]), w(), ht)
  end
end
