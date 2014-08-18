Element = class()

local g = love.graphics

function Element:init(data)
  self.parent = nil
  self.children = {}
  self.x = 0
  self.y = 0
  self.width = 0
  self.height = 0

  table.merge(data, self)
end

function Element:draw()
  self:render()
  self:renderChildren()
end

function Element:render()
  if self.background then
    if self.background.typeOf and self.background:typeOf('Drawable') then
      g.setColor(255, 255, 255)
      g.draw(self.background, self.x, self.y, 0, self.width / self.background:getWidth(), self.height / self.background:getHeight())
    else
      g.setColor(self.background)
      g.rectangle('fill', self.x, self.y, self.width, self.height)
    end
  end

  if self.border then
    g.setColor(self.border)
    g.rectangle('line', self.x, self.y, self.width, self.height)
  end
end

function Element:renderChildren()
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  table.with(self.children, 'draw')
  love.graphics.pop()
end

function Element:add(child)
  child.parent = self
  table.insert(self.children, child)
  if child.name and not self[child.name] then
    self[child.name] = child
  end
  return child
end