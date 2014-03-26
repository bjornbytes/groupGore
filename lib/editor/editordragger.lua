EditorDragger = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorDragger:init()
  self.dragging = false
  self.dragX = 0
  self.dragY = 0
  self.depth = -10000
  self.deselect = nil
end

function EditorDragger:update()
  if self.dragging then
    ovw.selector:each(function(prop)
      local ox, oy = ovw.grid:snap(prop._dragX, prop._dragY)
      local x, y = ovw.grid:snap(mouseX() - self.dragX, mouseY() - self.dragY)
      prop.x, prop.y = ox + x, oy + y
      invoke(prop, 'move') -- events
      ovw.event:emit('prop.move', {prop = prop, x = ox + x, y = oy + y})
    end)
  end
end

function EditorDragger:mousepressed(x, y, button)
  if button == 'l' and not love.keyboard.isDown('lshift') then
    if #ovw.selector.selection == 0 then
      local p = ovw.selector:pointTest(x, y)
      if p then ovw.selector:select(p) end
      self.deselect = p
    end
    self.dragging = true
    self.dragX = mouseX()
    self.dragY = mouseY()
    ovw.selector:each(function(prop)
      prop._dragX = prop.x
      prop._dragY = prop.y
    end)
  end
end

function EditorDragger:mousereleased(x, y, button)
  self.dragging = false
  if self.deselect then ovw.selector:deselect(self.deselect) end
end