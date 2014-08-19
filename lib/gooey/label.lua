Label = extend(Element)

local g = love.graphics

function Label:init(data)
  Element.init(self, data)
end

function Label:render()
  local u, v = self.owner.frame.width, self.owner.frame.height

  Element.render(self)

  if self.font and self.text and #self.text > 0 and self.color then
    local font, size = unpack(self.font)
    g.setFont(font, size * v)
    g.setColor(self.color)
    g.print(self.text, self.x * u, self.y * v)
  end
end