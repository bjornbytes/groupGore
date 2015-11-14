local Bloom = {}
Bloom.code = 'bloom'

local g = love.graphics

function Bloom:init()
  self:resize()
end

function Bloom:update()
  --
end

function Bloom:render(fn)
  data.media.shaders.threshold:send('threshold', 0.9)
  g.pop()
  g.setShader(data.media.shaders.threshold)
  g.push()
  g.scale(.25)
  ctx.view:worldPush()
  self.canvas:renderTo(fn)
  self.working:renderTo(fn)
  g.pop()
  g.pop()
  ctx.view:worldPush()
  g.setShader()
end

function Bloom:applyEffect(source, target)
  g.setCanvas(self.canvas)
  data.media.shaders.horizontalBlur:send('amount', .005)
  data.media.shaders.verticalBlur:send('amount', .005)
  g.setColor(255, 255, 255)
  for i = 1, 6 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.working:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.draw(self.working)
    end)
  end

  g.setShader()
  g.setCanvas(target)
  g.draw(source)
  love.graphics.setColor(255, 255, 255, 120)
  g.setBlendMode('additive')
  g.draw(self.canvas, 0, 0, 0, 4, 4)
  g.setBlendMode('alpha')
  g.setCanvas()

  self.canvas:clear()
  self.working:clear()
end

function Bloom:resize()
  local w, h = g.getDimensions()
  self.canvas = g.newCanvas(w / 4, h / 4)
  self.working = g.newCanvas(w / 4, h / 4)
end

return Bloom
