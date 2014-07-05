local Antialias = {}
Antialias.code = 'antialias'
Antialias.shader = data.media.shaders.fxaa

function Antialias:init()
  self:resize()
end

function Antialias:resize()
  self.shader:send('step', {1 / love.graphics.getWidth(), 1 / love.graphics.getHeight()})
end

return Antialias