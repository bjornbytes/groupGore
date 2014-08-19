Gooey = class()

local g = love.graphics

function Gooey:init(template)
  self.elements = {}
  self.stack = {}

  for i = 1, #template do
    local el = self:createElement(template[i])
    table.insert(self.elements, el)
    if el.name and not self[el.name] then
      self[el.name] = el
    end
  end
end

function Gooey:draw()
  self.frame = {x = 0, y = 0, width = love.graphics.getWidth(), height = love.graphics.getHeight()}
  for _, el in ipairs(self.elements) do el:draw() end
  assert(#self.stack == 0, 'Unbalanced stack operations')
  self.frame = nil
end

function Gooey:createElement(data)
  local el = _G[data.kind](data.properties)
  el.owner = self
  if not data.children then return el end
  for i = 1, #data.children or {} do
    el:add(createElement(data.children[i]))
  end
  return el
end

function Gooey:push(element)
  table.insert(self.stack, {x = self.frame.x, y = self.frame.y, width = self.frame.width, height = self.frame.height})
  self.frame.x = self.frame.x + element.x
  self.frame.y = self.frame.y + element.y
  self.frame.width = self.frame.width * element.width
  self.frame.height = self.frame.height * element.height
  love.graphics.push()
  love.graphics.translate(element.x, element.y)
end

function Gooey:pop(element)
  love.graphics.pop()
  table.merge(self.stack[#self.stack], self.frame)
  table.remove(self.stack)
end