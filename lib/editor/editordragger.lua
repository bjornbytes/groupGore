EditorDragger = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorDragger:init()
  self.dragging = false
  self.dragX = 0
  self.dragY = 0
  self.depth = -10000
end

function EditorDragger:update()
  if self.dragging then
    ovw.selector:each(function(prop)
      local ox, oy = ovw.grid:snap(prop._dragX, prop._dragY)
      local x, y = ovw.grid:snap(mouseX() - self.dragX, mouseY() - self.dragY)
      prop.x, prop.y = ox + x, oy + y
      invoke(prop, 'move') -- events
    end)
  end
end

function EditorDragger:mousepressed(x, y, button)
  if button == 'l' and not love.keyboard.isDown('lshift') then
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
end