Sound = class()

function Sound:init()
  self.sounds = {}
  self.mute = false
end

function Sound:play(name)
  if self.mute then return end
  self.sounds[name] = self.sounds[name] or love.audio.newSource('media/sounds/' .. name .. '.ogg')
  return self.sounds[name]:play()
end

function Sound:mute()
  self.mute = not self.mute
  love.audio.tag.all.stop()
end