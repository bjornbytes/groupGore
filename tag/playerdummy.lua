PlayerDummy = {}
setmetatable(PlayerDummy, {__index = Player})

function PlayerDummy:update()
  --
end