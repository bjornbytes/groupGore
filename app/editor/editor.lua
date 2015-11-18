Editor = class()

function Editor:load(options)
  self.options = options
  self.grid = EditorGrid()

  self.view = EditorView()
  self.effects = app.core.effects()
  self.effects:remove('deathDesaturate')
  self.event = app.core.event()
  self.collision = app.core.collision()
  self.map = app.map()
  self.dragger = EditorDragger()
  self.scaler = EditorScaler()
  self.selector = EditorSelector()
  self.deletor = EditorDeletor()
  self.saver = EditorSaver()
  self.debug = EditorDebug()

  self.widgets = {self.grid}
  self.components = {
    self.view,
    self.effects,
    self.dragger,
    self.scaler,
    self.deletor,
    self.selector,
    self.saver,
    self.map,
    self.debug
  }

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
end

function Editor:keypressed(key)
  table.each(self.components, f.egoexe('keypressed', key))
  table.each(self.widgets, f.egoexe('keypressed', key))
end

function Editor:keyreleased(key)
  if key == 'escape' then
    app.core.context:remove(ctx)
    app.core.context:add(Menu)
  end
end

function Editor:textinput(key)
  table.each(self.components, f.egoexe('textinput', key))
  table.each(self.widgets, f.egoexe('textinput', key))
end

function Editor:mousepressed(x, y, button)
  table.each(self.components, f.egoexe('mousepressed', x, y, button))
  table.each(self.widgets, f.egoexe('mousepressed', x, y, button))
end

function Editor:mousereleased(x, y, button)
  table.each(self.components, f.egoexe('mousereleased', x, y, button))
  table.each(self.widgets, f.egoexe('mousereleased', x, y, button))
end

function Editor:resize()
  self.view:resize()
end
