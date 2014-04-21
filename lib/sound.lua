Sound = class()

function Sound:init()
  self.sounds = {}
  self.mute = false

  ctx.event:on('sound.play', f.cur(self.play, self))
  ctx.event:on('sound.loop', f.cur(self.loop, self))
end

function Sound:play(data)
  local name = data.sound
  if self.mute then return end
  self.sounds[name] = self.sounds[name] or love.audio.newSource('media/sounds/' .. name .. '.ogg')
  return self.sounds[name]:play()
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
