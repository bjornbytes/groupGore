EditorState = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorState:init()
  self.states = {}
end

function EditorState:push()
  --
end

function EditorState:pop()
  self.states[#self.states] = nil
end

function EditorState:undo()
  --
end

function EditorState:redo()
  --
end

function EditorState:keypressed(key)
  if key == 'z' and love.keyboard.isDown('lctrl') then
    self:undo()
  end
end
