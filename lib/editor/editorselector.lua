EditorSelector = class()
EditorSelector.doubleClickSpeed = .5

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorSelector:init()
  self.selection = {}
  self.active = false
  self.depth = -10000
  self.lastClick = tick
  self.dragging = false
  self.dragStartX = nil
  self.dragStartY = nil
  ovw.view:register(self)
end

function EditorSelector:update()
  self.active = love.keyboard.isDown('lshift')
  if self.active and love.mouse.isDown('l', 'r') and math.distance(self.dragStartX, self.dragStartY, love.mouse.getPosition()) > 5 then
    self.dragging = true
  end
end

function EditorSelector:draw()
  love.graphics.setColor(0, 255, 255, 50)
  if self.active then
    table.each(ovw.map.props, function(prop)
      prop.shape:draw('line')
    end)
  end
  
  love.graphics.setColor(0, 255, 255, 100)
  for _, prop in ipairs(self.selection) do
    prop.shape:draw('fill')
  end
end

function EditorSelector:gui()
  if self.active and self.dragging then
    if love.keyboard.isDown('lctrl') then
      love.graphics.setColor(0, 255, 255, 150)
      love.graphics.line(self.dragStartX, self.dragStartY, love.mouse.getPosition())
    else
      love.graphics.setColor(0, 255, 255, 25)
      local x, y = self.dragStartX + .5, self.dragStartY + .5
      local w, h = love.mouse.getX() - self.dragStartX - 1, love.mouse.getY() - self.dragStartY - 1
      love.graphics.rectangle('fill', x, y, w, h)
      love.graphics.setColor(0, 255, 255, 150)
      love.graphics.rectangle('line', x, y, w, h)
    end
  end
end

function EditorSelector:pointTest(x, y)
  local shapes = ovw.collision.hc:shapesAt(x + ovw.view.x, y + ovw.view.y)
  return table.map(shapes, function(s) return s.owner end)
end

function EditorSelector:rectTest(x1, y1, x2, y2)
  if x1 > x2 then x1, x2 = x2, x1 end
  if y1 > y2 then y1, y2 = y2, y1 end
  x1, y1 = ovw.view:transform(x1, y1)
  x2, y2 = ovw.view:transform(x2, y2)
  local selectRect = ovw.collision.hc:addRectangle(x1, y1, x2 - x1, y2 - y1)
  
  local res = {}
  for shape in pairs(selectRect:neighbors()) do
    if selectRect:collidesWith(shape) then
      table.insert(res, shape.owner)
    end
  end

  ovw.collision.hc:remove(selectRect)
  
  return res
end

function EditorSelector:lineTest(x1, y1, x2, y2)
  x1, y1 = ovw.view:transform(x1, y1)
  x2, y2 = ovw.view:transform(x2, y2)
  local dis = math.distance(x1, y1, x2, y2)
  
  local res = {}
  for shape in pairs(ovw.collision.hc:shapesInRange(math.min(x1, x2), math.min(y1, y2), math.max(x1, x2), math.max(y1, y2))) do
    local intersects, d = shape:intersectsRay(x1, y1, x2 - x1, y2 - y1)
    if intersects then
      table.insert(res, shape.owner)
    end
  end

  return res
end

function EditorSelector:mousepressed(x, y, button)
  local function doubleClick()
    return (tick - self.lastClick) * tickRate <= self.doubleClickSpeed
  end

  if self.active then
    if button == 'l' then
      if doubleClick() then
        self:selectAll()
      else
        self:select(unpack(self:pointTest(x, y)))
      end
      self.lastClick = tick
      self.dragStartX = x
      self.dragStartY = y
    elseif button == 'r' then
      if doubleClick() then
        self:deselectAll()
      else
        self:deselect(unpack(self:pointTest(x, y)))
      end
      self.lastClick = tick
      self.dragStartX = x
      self.dragStartY = y
    end
  end
end

function EditorSelector:mousereleased(x, y, button)
  if self.active and self.dragging then
    local selector = love.keyboard.isDown('lctrl') and self.lineTest or self.rectTest
    local targets = selector(self, self.dragStartX, self.dragStartY, x, y)
    if button == 'l' then
      self:select(unpack(targets))
    elseif button == 'r' then
      self:deselect(unpack(targets))
    end
    self.dragging = false
  end
end

function EditorSelector:select(prop, ...)
  if not prop then return end

  if not self.selection[prop] then
    table.insert(self.selection, prop)
    self.selection[prop] = #self.selection
  end
  
  return self:select(...)
end

function EditorSelector:deselect(prop, ...)
  if not prop then return end

  if self.selection[prop] then
    for i = self.selection[prop] + 1, #self.selection do
      self.selection[self.selection[i]] = self.selection[self.selection[i]] - 1
    end
    table.remove(self.selection, self.selection[prop])
    self.selection[prop] = nil
  end
  
  return self:deselect(...)
end

function EditorSelector:selectAll()
  self:select(unpack(ovw.map.props))
end

function EditorSelector:deselectAll()
  self:deselect(unpack(ovw.map.props))
end

function EditorSelector:each(fn)
  for i = 1, #self.selection do
    fn(self.selection[i])
  end
end
