local testArena = {}

----------------
-- Meta
----------------
testArena.name = 'Test Arena'
testArena.width = 800
testArena.height = 600
testArena.weather = nil


----------------
-- Spawn Points
----------------
testArena.spawn = {}

testArena.spawn[purple] = {
    x = 64,
    y = 300
}

testArena.spawn[orange] = {
    x = testArena.width - 64,
    y = 300
}


----------------
-- Functions
----------------
testArena.activate = function(self)
  self.pointLimit = 5
end


----------------
-- Events
----------------
testArena.on = {}
testArena.on[evtDead] = function(self, data)
  local team = 1 - ctx.players:get(data.id).team
  self:score(team)
  if self.points[team] >= self.pointLimit then
    ctx.net:emit(evtChat, {message = (team == 0 and 'purple' or 'orange') .. ' team wins!'})
    self.points[purple] = 0
    self.points[orange] = 0
    self:score()
  end
end

return testArena
