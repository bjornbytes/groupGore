Container = class()

function Container:init()
  self.padding = 0
  self.background = {0, 0, 0, 0}
  self.items = {}
end

function Container:update()
  table.each(self.items, f.ego('update'))
end

function Container:draw(x, y, w, h)
  love.graphics.setColor(self.background)
  love.graphics.rectangle('fill', x, y, w, h)
  love.graphics.translate(-x, -y)
  table.each(self.items, f.ego('draw'))
end

function Container:mousepressed(x, y, button)
  table.each(self.items, f.ego('mousepressed', x, y, button))
end

function Container:textinput(key)
  table.each(self.items, f.ego('textinput', key))
end
