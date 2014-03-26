Editor = class()

function Editor:load()
  self.grid = EditorGrid()
  
  self.view = EditorView()
  self.menu = EditorMenu()
  self.dragger = EditorDragger()
  self.scaler = EditorScaler()
  self.selector = EditorSelector()
  self.deletor = EditorDeletor()
  self.map = Map()
  self.event = Event()
  
  self.widgets = {self.grid, self.dragger, self.scaler}
  self.components = {self.view, self.menu, self.dragger, self.scaler, self.deletor, self.selector, self.map}
  
  table.each(self.widgets, function(widget)
    if widget.draw and widget.depth then self.view:register(widget) end
  end)
end

function Editor:update()
  table.each(self.components, f.egoexe('update'))
  table.each(self.widgets, f.egoexe('update'))
end

function Editor:draw()
  self.view:draw()
  self.menu:draw()
end

function Editor:keypressed(key)
  local handlers = {
    ['escape'] = function() love.event.push('quit') end,
    ['s'] = function() if love.keyboard.isDown('lctrl') then self:save() end end
  }

  table.each(self.components, f.egoexe('keypressed', key))
  table.each(self.widgets, f.egoexe('keypressed', key))
  return f.exe(handlers[key])
end

function Editor:mousepressed(x, y, button)
  table.each(self.components, f.egoexe('mousepressed', x, y, button))
  table.each(self.widgets, f.egoexe('mousepressed', x, y, button))
end

function Editor:mousereleased(x, y, button)
  table.each(self.components, f.egoexe('mousereleased', x, y, button))
  table.each(self.widgets, f.egoexe('mousereleased', x, y, button))
end

function Editor:save()
  local str = 'return {'
  table.each(ovw.map.props, function(p)
    str = str .. invoke(p, 'save') .. ','
  end)
  str = str .. '}'
  love.filesystem.createDirectory('maps/' .. ovw.map.code)
  love.filesystem.write('maps/' .. ovw.map.code .. '/props.lua', str)
end