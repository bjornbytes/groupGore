PlayerDummy = {}
setmetatable(PlayerDummy, {__index = Player})

function PlayerDummy:activate()
	Player.activate(self)
end

function PlayerDummy:trace(data)
	local t = data.tick
	data.tick = nil
	data.id = nil
	data.angle = math.rad(data.angle)
	for i = t, tick do
		local dst = Players.history[self.id][i]
		if i == tick then dst = self end
		table.merge(data, dst)
		ovw.collision:refreshPlayer(self)
	end
end