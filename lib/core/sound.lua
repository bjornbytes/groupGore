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
  if _data.x and _data.y then
    sound:setPosition(_data.x, _data.y, _data.z or 0)
  end
  sound:setAttenuationDistances(400, 1000)
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
