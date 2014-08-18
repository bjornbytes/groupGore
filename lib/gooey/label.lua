Label = extend(Element)

local g = love.graphics

function Label:init()
  Element.init(self)
end

function Label:render()
  Element.render(self)

  if self.font and self.fontSize and self.text and #self.text > 0 and self.color then
    g.setFont(self.font, self.fontSize)
    g.setColor(self.color)
    g.print(self.text, self.x, self.y)
  end
end