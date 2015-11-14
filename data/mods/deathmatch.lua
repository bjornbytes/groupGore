local Deathmatch = {}
Deathmatch.code = 'deathmatch'

Deathmatch.pointsPerKill = 1
Deathmatch.experiencePerKill = 0

function Deathmatch:init()
  ctx.event:on(evtDead, function(data)
    if data.id == data.kill then return end

    local killer = ctx.players:get(data.kill)
    ctx.map:modExec('scoring', 'score', killer.team, self.pointsPerKill)
    ctx.map:modExec('experience', 'give', killer, self.experiencePerKill)
  end)
end

return Deathmatch
