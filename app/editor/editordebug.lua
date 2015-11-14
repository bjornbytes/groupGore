EditorDebug = class()

local g = love.graphics

function EditorDebug:init()
  self.depth = -1000000
  if ctx.view then ctx.view:register(self, 'gui') end
end

function EditorDebug:gui()
  local x = math.floor(ctx.view:worldMouseX() / ctx.grid.size) * ctx.grid.size
  local y = math.floor(ctx.view:worldMouseY() / ctx.grid.size) * ctx.grid.size
  local message = x .. ',' .. y

  local w, h = love.graphics.getDimensions()
  g.setFont('pixel', 8)
  g.setColor(0, 0, 0)
  g.print(message, w - g.getFont():getWidth(message) + 1, h - g.getFont():getHeight() + 1)
  g.setColor(255, 255, 255)
  g.print(message, w - g.getFont():getWidth(message), h - g.getFont():getHeight())
end
