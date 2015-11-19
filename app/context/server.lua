local Server = class()

Server.tag = 'server'

function Server:load()
  self.event = app.util.event()
  self.players = app.player.controller()
  self.spells = app.logic.spells()
  self.collision = app.logic.collision()
  self.buffs = app.logic.buffs()
  self.net = app.net.server()
  self.map = app.logic.map()

  for i = 1, 0 do
    local p = self.players.players[i]
    setmetatable(p, {__index = app.playerRobot})
    self.net:emit(app.net.core.events.class, {id = i, class = 1, team = i % 2})
  end

  self.event:on('game.quit', function()
    app.net.goregous:send({'killServer'})
    app.util.context:remove(ctx)
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
