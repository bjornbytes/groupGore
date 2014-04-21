local jungleCarnage = {}

----------------
-- Meta
----------------
jungleCarnage.name = 'Jungle Carnage'
jungleCarnage.width = 1600
jungleCarnage.height = 1200
jungleCarnage.weather = 'snow'


----------------
-- Spawn Points
----------------
jungleCarnage.spawn = {}

jungleCarnage.spawn[purple] = {
    x = 128,
    y = 128
}

jungleCarnage.spawn[orange] = {
    x = jungleCarnage.width - 128,
    y = jungleCarnage.height - 128
}


----------------
-- Functions
----------------
jungleCarnage.activate = function(self)
  self.pointLimit = 5
end


----------------
-- Events
----------------
jungleCarnage.on = {}
jungleCarnage.on[evtDead] = function(self, data)
  local team = 1 - ctx.players:get(data.id).team
  self:score(team)
  if self.points[team] >= self.pointLimit then
    ctx.net:emit(evtChat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
    self.points[purple] = 0
    self.points[orange] = 0
    self:score()
  end
end

return jungleCarnage
