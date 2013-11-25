PlayerDummy = {}
setmetatable(PlayerDummy, {__index = Player})

function PlayerDummy:activate()
	Player.activate(self)
end