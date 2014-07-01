local Vignette = {}
Vignette.code = 'vignette'
Vignette.shader = data.media.shaders.vignette

function Vignette:init()
  self.shader:send('radius', .85)
  self.shader:send('smooth', .45)
  self:resize()
end

function Vignette:resize()
  self.shader:send('frame', {ctx.view.frame.x, ctx.view.frame.y, ctx.view.frame.width, ctx.view.frame.height})
end

return Vignette