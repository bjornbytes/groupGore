local industria = {}

----------------
-- Meta
----------------
industria.name = 'Industria'
industria.width = 2432
industria.height = 3320


----------------
-- Spawn Points
----------------
industria.spawn = {}

industria.spawn[purple] = {
    x = 128,
    y = 128
}

industria.spawn[orange] = {
    x = industria.width - 128,
    y = industria.height - 128
}


----------------
-- Functions
----------------
industria.activate = function(self)
  self.pointLimit = 5
end


----------------
-- Events
----------------
industria.on = {}
industria.on[evtDead] = function(self, data)
  local team = 1 - ovw.players:get(data.id).team
  self:score(team)
  if self.points[team] >= self.pointLimit then
    ovw.net:emit(evtChat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
    self.points[purple] = 0
    self.points[orange] = 0
    self:score()
  end
end

return industria