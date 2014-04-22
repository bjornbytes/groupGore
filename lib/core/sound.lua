Sound = class()

function Sound:init()
  self.mute = false

  ctx.event:on('sound.play', f.cur(self.play, self))
  ctx.event:on('sound.loop', f.cur(self.loop, self))
end

function Sound:play(_data)
  local name = _data.sound
  if self.mute then return end
  return data.media.sounds[name]:play()
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
