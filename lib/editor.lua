Editor = class()

function Editor:init()
  self.selected = nil
  self.active = false
  self.depth = -10000
  ovw.view:register(self)
end

function Editor:update()
  if self.active then
    --
  end
end

function Editor:draw()
  if self.active then
    table.each(ovw.map.props, function(p)
      if self.selected == p then love.graphics.setColor(160, 255, 255, 160)
      else love.graphics.setColor(0, 255, 255, 100) end
      love.graphics.rectangle('fill', p:boundingBox())
    end)
  end
end

function Editor:mousepressed(x, y, button)
  self.selected = nil
  table.each(ovw.map.props, function(p)
    if math.inside(mouseX(), mouseY(), p:boundingBox()) then
      self.selected = p
    end
  end)
  if self.selected then return true end
end