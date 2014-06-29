local Vignette = {}
Vignette.code = 'vignette'
Vignette.shader = data.media.shaders.vignette

function Vignette:update()
  self.shader:send('frame', {ctx.view.frame.x, ctx.view.frame.y, ctx.view.frame.width, ctx.view.frame.height})
  self.shader:send('radius', .85)
  self.shader:send('smooth', .45)
end

return Vignette