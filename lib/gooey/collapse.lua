Collapse = class()

local g = love.graphics

local function getStr(self)
  return (self.open and '[-] ' or '[+] ') .. self.label
end

function Collapse:init()
  self.x = nil
  self.y = nil
  self.open = false
  self.label = ''
  self.contents = f.empty
  self.leftMargin = 16
end

function Collapse:mousepressed(x, y, button)
  if button == 'l' and self.x and self.y then
    g.setFontPixel('pixel', 8)
    if math.inside(x, y, self.x, self.y, g.getFont():getWidth(getStr(self)), g.getFont():getHeight()) then
      self.open = not self.open
    end
  end
end

function Collapse:draw(x, y)
  g.setFontPixel('pixel', 8)
  g.print(getStr(self), x, y)

  y = y + g.getFont():getHeight()
  if self.open then
    self.contents(x + self.leftMargin, y)
  end
end

function Collapse:getHeight()
  --
end
