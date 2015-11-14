MenuRibbon = class()

local g = love.graphics

function MenuRibbon:init()
  self.ribbons = {0, 0, 0, 0, 0}
  self.count = 3
  self.margin = .1
end

function MenuRibbon:test(x, y)
  local u, v = ctx.u, ctx.v
  local anchor = (.3 + (.8 - .3) / 2) * v

  g.setFont('BebasNeue', .065 * v)
  local fh = g.getFont():getHeight()

  for i = 1, self.count do
    local yy = anchor - (self.margin * v * ((self.count - 1) / 2)) + (self.margin * v * (i - 1)) - fh / 2
    if math.inside(x, y, 0, yy, u, fh) then return i end
  end

  return nil
end

function MenuRibbon:draw()
  local u, v = ctx.u, ctx.v
  local anchor = (.3 + (.8 - .3) / 2) * v

  g.setFont('BebasNeue', .065 * v)
  local fh = g.getFont():getHeight()

  local test = self:test(love.mouse.getPosition())
  for i = 1, self.count do
    if test == i then
      self.ribbons[i] = math.lerp(self.ribbons[i], 1, 20 * delta)
    else
      self.ribbons[i] = math.lerp(self.ribbons[i], 0, 30 * delta)
    end

    local ht = math.ceil(fh * self.ribbons[i])

    g.setColor(0, 0, 0, 80 * self.ribbons[i])
    g.rectangle('fill', 0, anchor - (self.margin * v * ((self.count - 1) / 2)) + (self.margin * v * (i - 1)) - math.round(fh / 2 * self.ribbons[i]), u, ht)
  end
end

