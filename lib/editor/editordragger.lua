EditorDragger = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorDragger:init()
  self.dragging = false
  self.dragX = 0
  self.dragY = 0
  self.depth = -10000
  self.deselect = false
end

function EditorDragger:update()
  if self.dragging then
    ovw.selector:each(function(prop)
      local ox, oy = ovw.grid:snap(prop._dragX, prop._dragY)
      local x, y = ovw.grid:snap(ovw.view:mouseX() - self.dragX, ovw.view:mouseY() - self.dragY)
      prop.x, prop.y = ox + x, oy + y
      ovw.event:emit('prop.move', {prop = prop, x = ox + x, y = oy + y})
    end)
  end
end

function EditorDragger:mousepressed(x, y, button)  
  if button == 'l' then
    self.deselect = false
    if love.keyboard.isDown('lshift') then return end
    if #ovw.selector.selection == 0 then
      ovw.selector:select(unpack(ovw.selector:pointTest(x, y)))
      self.deselect = true
    end
    self.dragging = true
    self.dragX = ovw.view:mouseX()
    self.dragY = ovw.view:mouseY()
    ovw.selector:each(function(prop)
      prop._dragX = prop.x
      prop._dragY = prop.y
    end)
  end
end

function EditorDragger:mousereleased(x, y, button)
  self.dragging = false
  if self.deselect then ovw.selector:deselectAll() end
  ovw.state:push()
end
