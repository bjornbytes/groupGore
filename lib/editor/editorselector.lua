EditorSelector = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorSelector:init()
  self.selection = {}
  self.active = false
  self.depth = -10000
  ovw.view:register(self)
end

function EditorSelector:update()
  self.active = love.keyboard.isDown('lshift')
end

function EditorSelector:draw()
  love.graphics.setColor(0, 255, 255, 100)
  for _, p in ipairs(self.selection) do
    love.graphics.rectangle('fill', invoke(p, 'boundingBox'))
  end
end

function EditorSelector:pointTest(x, y)
  for i = 1, #ovw.map.props do
    local p = ovw.map.props[i]
    local x, y, w, h = invoke(p, 'boundingBox')
    if math.inside(mouseX(), mouseY(), x, y, w, h) then
      return p
    end
  end
end

function EditorSelector:mousepressed(x, y, button)
  if self.active then
    if button == 'l' then
      local p = self:pointTest(x, y)
      if p then self:toggleSelect(p) end
    elseif button == 'r' then
      self:deselectAll()
    end
  end
end

function EditorSelector:select(prop)
  if not self.selection[prop] then self:toggleSelect(prop) end
end

function EditorSelector:deselect(prop)
  if self.selection[prop] then self:toggleSelect(prop) end
end

function EditorSelector:toggleSelect(prop)
  if self.selection[prop] then
    for i = self.selection[prop] + 1, #self.selection do
      self.selection[self.selection[i]] = self.selection[self.selection[i]] - 1
    end
    table.remove(self.selection, self.selection[prop])
    self.selection[prop] = nil
  else
    table.insert(self.selection, prop)
    self.selection[prop] = #self.selection
  end
end

function EditorSelector:selectAll()
  table.each(ovw.map.props, f.cur(self.select, self))
end

function EditorSelector:deselectAll()
  table.clear(self.selection)
end

function EditorSelector:each(fn)
  for i = 1, #self.selection do
    fn(self.selection[i])
  end
end