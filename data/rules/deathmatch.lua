local Deathmatch = {}

Deathmatch.code = 'deathmatch'

function Deathmatch:init()
  self.points = {}
  self.points[purple] = 0
  self.points[orange] = 0
  self.pointLimit = 5
  self.winner = nil
  self.restartTimer = 0

  ctx.event:on(evtDead, function(data)
    if self.restartTimer > 0 or data.id == data.kill then return end
    local team = 1 - ctx.players:get(data.id).team
    self.points[team] = self.points[team] + 1
    if self.points[team] >= self.pointLimit then
      ctx.net:emit(evtChat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
      self.winner = team
      self.restartTimer = 6
    end
  end)

  ctx.event:on('game.restart', function(data)
    self.points[purple] = 0
    self.points[orange] = 0
    self.winner = nil
    self.restartTimer = 0
  end)
end

function Deathmatch:update()
  self.restartTimer = timer.rot(self.restartTimer, function()
    self.winner = nil
    ctx.event:emit('game.quit')
  end)
end

return Deathmatch