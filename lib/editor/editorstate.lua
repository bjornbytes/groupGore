EditorState = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorState:init()
  --
end

function EditorState:push()
  --
end

function EditorState:pop()
  --
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