EditorScaler = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorScaler:init()
  self.scaling = nil
  self.scaleAnchor = nil
  self.scaleOriginX = 0
  self.scaleOriginY = 0
  self.scaleHandleX = 0
  self.scaleHandleY = 0
  self.depth = -10000
end

function EditorScaler:update()
  if self.scaling then
    local mx, my = mouseX(), mouseY()
    local winc, hinc = ovw.grid:snap(mx - self.scaleOriginX, my - self.scaleOriginY)
    if true then
      local ox, oy = self.scaleAnchor[1] + (self.scaleAnchor[3] / 2), self.scaleAnchor[2] + (self.scaleAnchor[4] / 2)
      invoke(self.scaling, 'scale', self.scaleHandleX, self.scaleHandleY, winc, hinc, unpack(self.scaleAnchor))
    end
  end
end

function EditorScaler:draw()
  if self.scaling then
    love.graphics.setColor(0, 255, 255, 200)
    local x, y, w, h = invoke(self.scaling, 'boundingBox')
    love.graphics.line(x, y, x + 16, y)
    love.graphics.line(x, y, x, y + 16)
    love.graphics.line(x + w - 16, y, x + w, y)
    love.graphics.line(x + w, y, x + w, y + 16)
    love.graphics.line(x, y + h - 16, x, y + h)
    love.graphics.line(x, y + h, x + 16, y + h)
    love.graphics.line(x + w - 16, y + h, x + w, y + h)
    love.graphics.line(x + w, y + h - 16, x + w, y + h)
  end
end

function EditorScaler:mousepressed(x, y, button)
  if button == 'r' then
    table.each(ovw.map.props, function(p)
      local x, y, w, h = invoke(p, 'boundingBox')
      if math.inside(mouseX(), mouseY(), x, y, w, h) then
        self.scaling = p
        self.scaleHandleX = mouseX() > x + (w / 2) and 1 or -1
        self.scaleHandleY = mouseY() > y + (h / 2) and 1 or -1
        self.scaleOriginX = mouseX()
        self.scaleOriginY = mouseY()
        self.scaleAnchor = {x, y, w, h}
      end
    end)
  end
end

function EditorScaler:mousereleased(x, y, button)
  self.scaling = nil
end