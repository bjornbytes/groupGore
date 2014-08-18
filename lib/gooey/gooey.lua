Gooey = class()

local g = love.graphics

local function createElement(data)
  local el = _G[data.kind](data.properties)
  if not data.children then return el end
  for i = 1, #data.children or {} do
    el:add(createElement(data.children[i]))
  end
  return el
end

function Gooey:init(template)
  self.elements = {}

  for i = 1, #template do
    local el = createElement(template[i])
    table.insert(self.elements, el)
    if el.name and not self[el.name] then
      self[el.name] = el
    end
  end
end

function Gooey:draw()
  g.push()
  g.scale(g.getDimensions())
  table.with(self.elements, 'draw')
  g.pop()
end