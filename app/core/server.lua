local Server = class()

Server.tag = 'server'

function Server:load()
  self.event = app.core.event()
  self.players = app.players()
  self.spells = app.core.spells()
  self.collision = app.core.collision()
  self.buffs = app.core.buffs()
  self.net = app.netServer()
  self.map = app.map()

  for i = 1, 0 do
    local p = self.players.players[i]
    setmetatable(p, {__index = app.playerRobot})
    self.net:emit(app.core.net.events.class, {id = i, class = 1, team = i % 2})
  end

  self.event:on('game.quit', function()
    goregous:send({'killServer'})
    app.core.context:remove(ctx)
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

return Server
