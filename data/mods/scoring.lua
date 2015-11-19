local Scoring = {}

Scoring.code = 'scoring'

Scoring.limit = 5

function Scoring:init()
  self.points = {}
  self.points[purple] = 0
  self.points[orange] = 0
  self.winner = nil
  self.restartTimer = 0

  ctx.event:on('game.restart', function(data)
    self.points[purple] = 0
    self.points[orange] = 0
    self.winner = nil
    self.restartTimer = 0
  end)
end

function Scoring:update()
  self.restartTimer = timer.rot(self.restartTimer, function()
    self.winner = nil
    ctx.event:emit('game.quit')
  end)
end

function Scoring:score(team, amount)
  self.points[team] = self.points[team] + amount
  if self.points[team] >= self.limit then
    self:win(team)
  end
end

function Scoring:win(team)
  ctx.net:emit(app.core.net.events.chat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
  self.winner = team
  self.restartTimer = 6
end

return Scoring
