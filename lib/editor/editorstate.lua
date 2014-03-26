EditorState = class()

function EditorState:init()
  self.states = table.copy(ovw.map.props)
end

function EditorState:push()
  table.insert(self.states, table.deltas(self.states[#self.states], ovw.map.props))
end

function EditorState:pop()
  self.states[#self.states] = nil
end

function EditorState:undo()
  
end

function EditorState:redo()
  --
end