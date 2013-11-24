PlayerDummy = {}
setmetatable(PlayerDummy, {__index = Player})

function PlayerDummy:activate()
	Player.activate(self)
end

function PlayerDummy:update()
  --
end

function PlayerDummy:trace(data)
  if #data == 0 then return end

  local idx = 1
  for i = data[1].tick, tick do
    if data[idx + 1] and data[idx + 1].tick == i then idx = idx + 1 end
    
    local dst = (i == tick) and self or (Players.history[self.id][i] or self)
    table.merge(table.except(data[idx], {'tick', 'events'}), dst)
    if Players.history[self.id][i - 1] then
      dst.angle = math.anglerp(dst.angle, Players.history[self.id][i - 1].angle, .5)
    end
  end
end
