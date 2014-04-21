Editor = class()

function Editor:load()
  self.grid = EditorGrid()
  
  self.view = EditorView()
  self.event = Event()
  self.collision = Collision()
  self.map = Map()
  self.menu = EditorMenu()
  self.dragger = EditorDragger()
  self.scaler = EditorScaler()
  self.selector = EditorSelector()
  self.deletor = EditorDeletor()
  self.state = EditorState()
  self.saver = EditorSaver()
  
  self.widgets = {self.grid}
  self.components = {
    self.view,
    self.menu,
    self.dragger,
    self.scaler,
    self.deletor,
    self.selector,
    self.state,
    self.saver,
    self.map
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
  self.menu:draw()
end

function Editor:keypressed(key)
  if key == 'escape' then
    Context:remove(ctx)
    Context:add(Menu)
  end
  
  table.each(self.components, f.egoexe('keypressed', key))
  table.each(self.widgets, f.egoexe('keypressed', key))
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
