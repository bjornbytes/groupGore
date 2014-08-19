Element = class()

local g = love.graphics

Element.x, Element.y = 0, 0
Element.width, Element.height = 1, 1

function Element:init(data)
  self.parent = nil
  self.children = {}

  table.merge(data, self)
end

function Element:draw()
  self:render()
  self:renderChildren()
end

function Element:render()
  local u, v = self.owner.frame.width, self.owner.frame.height

  if self.background then
    if self.background.typeOf and self.background:typeOf('Drawable') then
      g.setColor(255, 255, 255)
      g.draw(self.background, self.x * u, self.y * v, 0, self.width / self.background:getWidth() * u, self.height / self.background:getHeight() * v)
    else
      g.setColor(self.background)
      g.rectangle('fill', self.x * u, self.y * v, self.width * u, self.height * v)
    end
  end

  if self.border then
    g.setColor(self.border)
    g.setLineWidth(.01)
    g.rectangle('line', self.x * u, self.y * v, self.width * u, self.height * v)
  end
end

function Element:renderChildren()
  self.owner:push(self)
  table.with(self.children, 'draw')
  self.owner:pop(self)
end

function Element:add(child)
  child.parent = self
  child.owner = self.owner
  table.insert(self.children, child)

  if child.name then
    if child.name:find('[]') then
      child.name = child.name:sub(1, -2)
      if not self[child.name] then
        self[child.name] = self[child.name] or {}
        table.insert(self[child.name], child)
      end
    elseif not self[child.name] then
      self[child.name] = child
    end
  end

  return child
end