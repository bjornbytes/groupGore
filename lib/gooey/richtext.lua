local rich = require 'lib/deps/richtext/richtext'

RichText = extend(Element)

local g = love.graphics

function RichText:init(data)
  Element.init(self, data)
end

function RichText:render()
  local u, v = self.owner.frame.width, self.owner.frame.height

  --Element.render(self)

  local font, size = unpack(self.font)
  g.setFont(font, size * v)

  if not self.rt then self.rt = rich.new(self.richtext) end

  self.rt:draw(self.x * u, self.y * v)
end