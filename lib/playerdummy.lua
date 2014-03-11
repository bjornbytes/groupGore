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

function PlayerDummy:drawPosition()
	local t = tick - (interp / tickRate)
	local prev, cur = ovw.players.history[self.id][t - 1], ovw.players.history[self.id][t]
	if prev then
		prev, cur = {x = prev.x, y = prev.y}, {x = cur.x, y = cur.y}
		local interp = table.interpolate(prev, cur, tickDelta / tickRate)
		return interp.x, interp.y
	end
	
	return 0, 0
end

function PlayerDummy:trace(data)
	local t = data.tick
	data.tick = nil
	data.id = nil
	if data.angle then data.angle = math.rad(data.angle) end
	for i = t, tick do
		local dst = ovw.players.history[self.id][i]
		if i == tick then dst = self end
		table.merge(data, dst)
		ovw.collision:refreshPlayer(self)
	end
end