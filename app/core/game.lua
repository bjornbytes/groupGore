local Game = class()

Game.tag = 'client'

function Game:load(options)
	self.options = options
  self.event = app.core.event()
  self.net = app.netClient()
  self.input = app.core.input()
  self.view = app.core.view()
  self.collision = app.core.collision()
  self.players = app.players()
  self.spells = app.core.spells()
  self.buffs = app.core.buffs()
  self.particles = app.core.particles()
  self.effects = app.core.effects()
  self.sound = app.core.sound()
  self.map = app.map()
  self.hud = Hud()

  self.event:on('game.quit', function(data)
    app.core.context:remove(ctx)
    app.core.context:add(Menu)
  end)
end

function Game:update()
  self.net:update()
  self.buffs:update()
  self.players:update()
  self.spells:update()
  self.particles:update()
  self.effects:update()
  self.map:update()
  self.view:update()
  self.sound:update()
  self.hud:update()
end

function Game:draw()
  self.view:draw()
end

function Game:quit()
  self.net:quit()
end

function Game:mousepressed(...) self.hud:mousepressed(...) end
function Game:mousereleased(...) self.hud:mousereleased(...) end
function Game:keypressed(key) self.hud:keypressed(key) end
function Game:keyreleased(key) self.hud:keyreleased(key) end
function Game:textinput(character) self.hud:textinput(character) end

function Game:resize()
  self.view:resize()
  self.hud:resize()
  self.effects:resize()
end

return Game
