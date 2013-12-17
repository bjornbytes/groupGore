PlayerDummy = {}
setmetatable(PlayerDummy, {__index = Player})

function PlayerDummy:activate()
	Player.activate(self)
end

function PlayerDummy:draw()
	if self.ded then return end
	local t = tick - (interp / tickRate)
	local previous = ovw.players.history[self.id][t - 1]
	local current = ovw.players.history[self.id][t]
	if current and previous then
		Player.draw(table.interpolate(previous, current, tickDelta / tickRate))
	end
end

function PlayerDummy:trace(data)
	local t = data.tick
	data.tick = nil
	data.id = nil
	data.angle = math.rad(data.angle)
	for i = t, tick do
		local dst = ovw.players.history[self.id][i]
		if i == tick then dst = self end
		table.merge(data, dst)
		ovw.collision:refreshPlayer(self)
	end
end