EditorDragger = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorDragger:init()
  self.dragging = nil
  self.dragOffsetX = 0
  self.dragOffsetY = 0
  self.depth = -10000
end

function EditorDragger:update()
  if self.dragging then
    local x, y = self.dragging.x, self.dragging.y
    local tx, ty = ovw.grid:snap(mouseX() - self.dragOffsetX, mouseY() - self.dragOffsetY)
    if x ~= tx or y ~= ty then
      invoke(self.dragging, 'dragTo', tx, ty)
    end
  end
end

function EditorDragger:draw()
  if self.dragging then
    love.graphics.setColor(0, 255, 255, 200)
    love.graphics.rectangle('line', invoke(self.dragging, 'boundingBox'))
  end
end

function EditorDragger:mousepressed(x, y, button)
  if button == 'l' then
    table.each(ovw.map.props, function(p)
      local x, y, w, h = invoke(p, 'boundingBox')
      if math.inside(mouseX(), mouseY(), x, y, w, h) then
        self.dragging = p
        self.dragOffsetX = mouseX() - x
        self.dragOffsetY = mouseY() - y
      end
    end)
  end
end

function EditorDragger:mousereleased(x, y, button)
  self.dragging = nil
end