local Dragger = class()

local function invoke(x, k, ...) return x.editor[k](x, ...) end

function Dragger:init()
  self.dragging = false
  self.dragX = 0
  self.dragY = 0
  self.depth = -10000
  self.deselect = false
end

function Dragger:update()
  if self.dragging then
    ctx.selector:each(function(prop)
      local ox, oy = ctx.grid:snap(prop._dragX, prop._dragY)
      local x, y = ctx.grid:snap(ctx.view:worldMouseX() - self.dragX, ctx.view:worldMouseY() - self.dragY)
      prop.x, prop.y = ox + x, oy + y
      ctx.event:emit('collision.move', {object = prop})
    end)
  end
end

function Dragger:mousepressed(x, y, button)
  if button == 'l' then
    self.deselect = false
    if love.keyboard.isDown('lshift') then return end
    if #ctx.selector.selection == 0 then
      ctx.selector:select(unpack(ctx.selector:pointTest(x, y)))
      self.deselect = true
    end
    self.dragging = true
    self.dragX = ctx.view:worldMouseX()
    self.dragY = ctx.view:worldMouseY()
    ctx.selector:each(function(prop)
      prop._dragX = prop.x
      prop._dragY = prop.y
    end)
  end
end

function Dragger:mousereleased(x, y, button)
  self.dragging = false
  if self.deselect then ctx.selector:deselectAll() end
end

return Dragger
