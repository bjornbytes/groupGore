EditorMirror = class()

local g = love.graphics

function EditorMirror:init()
  self.horizontal = true
  self.vertical = true
  
  ovw.event:on('prop.create', function(self, prop)
    
  end)
end

function EditorMirror:draw()
  --
end

function EditorMirror:keypressed(key)
  --
end