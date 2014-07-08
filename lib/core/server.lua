Server = class()

Server.tag = 'server'

function Server:load()
  self.event = Event()
  self.players = Players()
  self.spells = Spells()
  self.collision = Collision()
  self.buffs = Buffs()
  self.net = NetServer()
  self.map = Map()

  for i = 1, 4 do
    local p = self.players.players[i]
    setmetatable(p, {__index = PlayerRobot})
    self.net:emit(evtClass, {id = i, class = 1, team = i % 2})
  end

  self.event:on('game.quit', function()
    goregous:send({'killServer'})
    Context:remove(ctx)
  end)
end

function Server:update()
  self.net:update()
  self.buffs:update()
  self.players:update()
  self.spells:update()
  self.map:update()
  self.net:sync()
end

function Server:quit()
  self.net:quit()
end