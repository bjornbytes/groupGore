Sound = class()

function Sound:init()
  self.mute = false

  ctx.event:on('sound.play', f.cur(self.play, self))
  ctx.event:on('sound.loop', f.cur(self.loop, self))
end

function Sound:update()
  love.audio.setPosition(ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2, 200)
end

function Sound:play(_data)
  local name = _data.sound
  if self.mute then return end
  local sound = data.media.sounds[name]:play()
  sound:setRelative(_data.relative)
  sound:setPosition(_data.x or 0, _data.y or 0, _data.z or 0)
  sound:setAttenuationDistances(_data.minrange or 400, _data.maxrange or 1000)
  return sound
end

function Sound:loop(data)
  local sound = self:play(data)
  if sound then sound:setLooping(true) end
  return sound
end

function Sound:mute()
  self.mute = not self.mute
  love.audio.tag.all.stop()
end
