local MotionBlur = {}
MotionBlur.code = 'motionBlur'

function MotionBlur:init()
  self:resize()
end

function MotionBlur:update()
  local v = ctx.view
  if v.target then
    local d = math.sqrt(math.abs(math.distance(v.x, v.y, v.target.x, v.target.y) - math.distance(v.prevx, v.prevy, v.target.x, v.target.y)))
    local dir = math.direction(v.x, v.y, v.prevx, v.prevy)
    self.shader:send('velocity', {math.dx(d, dir), math.dy(d, dir)})
  end
end

function MotionBlur:resize()
  self.shader = data.media.shaders.motionBlur
end

return MotionBlur
