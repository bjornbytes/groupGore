local Editor = class()

function Editor:load(options)
  self.options = options
  self.grid = app.ui.editor.grid()

  self.event = app.util.event()
  self.view = app.ui.editor.view()
  self.effects = app.media.effects()
  self.effects:remove('deathDesaturate')
  self.collision = app.logic.collision()
  self.map = app.logic.map()
  self.dragger = app.ui.editor.dragger()
  self.scaler = app.ui.editor.scaler()
  self.selector = app.ui.editor.selector()
  self.deletor = app.ui.editor.deletor()
  self.saver = app.ui.editor.saver()
  self.debug = app.ui.editor.debug()

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
    app.util.context:remove(ctx)
    app.util.context:add(app.context.menu)
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

return Editor
