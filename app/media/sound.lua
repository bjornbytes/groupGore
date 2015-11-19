local Sound = class()

function Sound:init()
  self.mute = false
  self.reposition = {}

  ctx.event:on('sound.play', f.cur(self.play, self))
  ctx.event:on('sound.loop', f.cur(self.loop, self))

  love.audio.setDistanceModel('linear clamped')
end

function Sound:update()
  love.audio.setPosition(ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2, 200)
  for i = #self.reposition, 1, -1 do
    if self.reposition[i]:isStopped() then
      table.remove(self.reposition, i)
    else
      self.reposition[i]:setPosition(ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2, 200)
    end
  end
end

function Sound:play(_data)
  local name = _data.sound
  if self.mute then return end
  local sound = data.media.sounds[name]:play()
  if _data.gui then
    _data.relative = true
    _data.x, _data.y = 0, 0
    table.insert(self.reposition, sound)
  end
  sound:setRelative(_data.relative or false)
  sound:setRolloff(_data.rolloff or 1)
  sound:setPosition(_data.x or 0, _data.y or 0, _data.z or 0)
  sound:setAttenuationDistances(_data.minrange or 350, _data.maxrange or 1000)
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

return Sound
