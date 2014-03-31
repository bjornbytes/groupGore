Container = class()

function Container:init()
  self.x = 0
  self.y = 0
  self.w = 0
  self.h = 0
  self.padding = 0
  self.background = {0, 0, 0, 0}
  self.items = {}
end

function Container:update()
  table.each(self.items, f.ego('update'))
end

function Container:draw()
  love.graphics.setColor(self.background)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  love.graphics.translate(-self.x, -self.y)
  table.each(self.items, f.ego('draw'))
end

function Container:mousepressed(x, y, button)
  table.each(self.items, f.ego('mousepressed', x, y, button))
end

function Container:textinput(key)
  table.each(self.items, f.ego('textinput', key))
end
