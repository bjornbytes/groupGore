Editor = class()

function Editor:load()
  self.grid = EditorGrid()
  self.dragger = EditorDragger()
  self.scaler = EditorScaler()
  self.view = EditorView()
  self.event = Event()
  self.map = Map()
  
  self.widgets = {self.grid, self.dragger, self.scaler}
  table.each(self.widgets, function(widget)
    if widget.draw and widget.depth then self.view:register(widget) end
  end)
end

function Editor:update()
  self.view:update()
  self.map:update()
  table.each(self.widgets, f.egoexe('update'))
end

function Editor:draw()
  self.view:draw()
end

function Editor:keypressed(key)
  local handlers = {
    ['escape'] = function() love.event.push('quit') end,
    ['delete'] = function()
      table.each(ovw.map.props, function(p)
        if math.inside(mouseX(), mouseY(), invoke(p, 'boundingBox')) then
          self.view:unregister(p)
          ovw.map.props = table.filter(ovw.map.props, function(prop) return p ~= prop end)
        end
      end)
    end,
    ['s'] = function()
      if love.keyboard.isDown('lctrl') then
        local str = 'return {'
        table.each(ovw.map.props, function(p)
          str = str .. invoke(p, 'save') .. ','
        end)
        str = str .. '}'
        love.filesystem.createDirectory('maps/' .. ovw.map.code)
        love.filesystem.write('maps/' .. ovw.map.code .. '/props.lua', str)
      end
    end
  }

  table.each(self.widgets, f.egoexe('keypressed', key))
  return f.exe(handlers[key])
end

function Editor:mousepressed(x, y, button)
  self.view:mousepressed(x, y, button)
  table.each(self.widgets, f.egoexe('mousepressed', x, y, button))
end

function Editor:mousereleased(x, y, button)
  table.each(self.widgets, f.egoexe('mousereleased', x, y, button))
end