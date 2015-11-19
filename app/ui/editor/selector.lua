local Selector = class()
Selector.doubleClickSpeed = .25

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function Selector:init()
  self.selection = {}
  self.active = false
  self.lastClick = tick
  self.lastButton = nil
  self.dragging = false
  self.dragStartX = nil
  self.dragStartY = nil
  self.depth = -100000
  ctx.view:register(self, 'draw')
  ctx.view:register(self, 'gui')
end

function Selector:update()
  self.active = love.keyboard.isDown('lshift')
  if self.active and love.mouse.isDown('l', 'r') and math.distance(self.dragStartX, self.dragStartY, love.mouse.getPosition()) > 5 then
    self.dragging = true
  end
end

function Selector:draw()
  love.graphics.setColor(0, 255, 255, 100)
  for _, prop in ipairs(self.selection) do
    if prop.shape then prop.shape:draw('fill') end
  end

  love.graphics.setColor(0, 255, 255)
  if self.active then
    table.each(ctx.map.props, function(prop)
      if prop.shape then prop.shape:draw('line') end
    end)
  end
end

function Selector:gui()
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

function Selector:pointTest(x, y)
  local shapes = ctx.collision.hc:shapesAt(ctx.view:worldPoint(x, y))
  return table.map(shapes, function(s) return s.owner end)
end

function Selector:rectTest(x1, y1, x2, y2)
  if x1 > x2 then x1, x2 = x2, x1 end
  if y1 > y2 then y1, y2 = y2, y1 end
  x1, y1 = ctx.view:worldPoint(x1, y1)
  x2, y2 = ctx.view:worldPoint(x2, y2)
  local selectRect = ctx.collision.hc:addRectangle(x1, y1, x2 - x1, y2 - y1)

  local res = {}
  for shape in pairs(selectRect:neighbors()) do
    if selectRect:collidesWith(shape) then
      table.insert(res, shape.owner)
    end
  end

  ctx.collision.hc:remove(selectRect)

  return res
end

function Selector:lineTest(x1, y1, x2, y2)
  x1, y1 = ctx.view:worldPoint(x1, y1)
  x2, y2 = ctx.view:worldPoint(x2, y2)
  local dis = math.distance(x1, y1, x2, y2)

  local res = {}
  for shape in pairs(ctx.collision.hc:shapesInRange(math.min(x1, x2), math.min(y1, y2), math.max(x1, x2), math.max(y1, y2))) do
    local intersects, d = shape:intersectsRay(x1, y1, x2 - x1, y2 - y1)
    if intersects then
      table.insert(res, shape.owner)
    end
  end

  return res
end

function Selector:mousepressed(x, y, button)
  local function doubleClick()
    return button == self.lastButton and (tick - self.lastClick) * tickRate <= self.doubleClickSpeed
  end

  if self.active then
    if button == 'l' then
      if doubleClick() then
        self:selectAll()
      else
        self:select(unpack(self:pointTest(x, y)))
      end
      self.lastClick = tick
      self.lastButton = button
      self.dragStartX = x
      self.dragStartY = y
    elseif button == 'r' then
      if doubleClick() then
        self:deselectAll()
      else
        self:deselect(unpack(self:pointTest(x, y)))
      end
      self.lastClick = tick
      self.lastButton = button
      self.dragStartX = x
      self.dragStartY = y
    end
  end
end

function Selector:mousereleased(x, y, button)
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

function Selector:select(prop, ...)
  if not prop then return end

  if not self.selection[prop] then
    table.insert(self.selection, prop)
    self.selection[prop] = #self.selection
  end

  return self:select(...)
end

function Selector:deselect(prop, ...)
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

function Selector:selectAll()
  self:select(unpack(ctx.map.props))
end

function Selector:deselectAll()
  self:deselect(unpack(ctx.map.props))
end

function Selector:each(fn)
  for i = 1, #self.selection do
    fn(self.selection[i])
  end
end

return Selector
