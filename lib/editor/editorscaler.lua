EditorScaler = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function EditorScaler:init()
  self.scaling = nil
  self.scaleOriginX = 0
  self.scaleOriginY = 0
  self.scaleHandleX = 0
  self.scaleHandleY = 0
  self.depth = -10000
  ctx.view:register(self)
end

function EditorScaler:update()
  if self.scaling then
    local prop = self.scaling
    local mx, my = ctx.view:transform(love.mouse.getPosition())
    if prop.collision.shape == 'rectangle' then
      local xinc, yinc = ctx.grid:snap(mx - self.scaleOriginX, my - self.scaleOriginY)
      local newWidth = prop._scaleW + (xinc * math.sign(self.scaleHandleX))
      local newHeight = prop._scaleH + (yinc * math.sign(self.scaleHandleY))
      if newWidth > 0 and newHeight > 0 then
        prop.x = prop._scaleX
        prop.y = prop._scaleY
        prop.width = prop._scaleW + (xinc * math.sign(self.scaleHandleX))
        prop.height = prop._scaleH + (yinc * math.sign(self.scaleHandleY))
        if self.scaleHandleX < 0 then prop.x = prop.x + xinc end
        if self.scaleHandleY < 0 then prop.y = prop.y + yinc end
        ctx.event:emit('collision.detach', {object = prop})
        ctx.event:emit('collision.attach', {object = prop})
      end
    else
      --
    end
  end
end

function EditorScaler:draw()
  if self.scaling and self.scaling.collision.shape == 'rectangle' then
    love.graphics.setColor(0, 255, 255, 200)
    local x, y, w, h = self.scaling.x, self.scaling.y, self.scaling.width, self.scaling.height
    x, y = x - 2, y - 2
    w, h = w + 4, h + 4
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
  if button == 'r' and not love.keyboard.isDown('lshift') then
    local p = ctx.selector:pointTest(x, y)[1]
    if p then
      local x, y = ctx.view:transform(x, y)
      self.scaling = p
      self.scaleOriginX = ctx.view:mouseX()
      self.scaleOriginY = ctx.view:mouseY()
      p._scaleX = p.x
      p._scaleY = p.y
      if p.collision.shape == 'rectangle' then
        p._scaleW = p.width
        p._scaleH = p.height
        self.scaleHandleX = x > p.x + (p.width / 2) and 1 or -1
        self.scaleHandleY = y > p.y + (p.height / 2) and 1 or -1
      else
        self.scaleHandleX, self.scaleHandleY = 1, 1
      end
    end
  end
end

function EditorScaler:mousereleased(x, y, button)
  self.scaling = nil
end
