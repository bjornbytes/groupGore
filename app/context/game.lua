local Game = class()

Game.tag = 'client'

function Game:load(options)
	self.options = options
  self.event = app.util.event()
  self.net = app.net.client()
  self.input = app.util.input()
  self.view = app.media.view()
  self.collision = app.logic.collision()
  self.players = app.player.controller()
  self.spells = app.logic.spells()
  self.buffs = app.logic.buffs()
  self.particles = app.media.particles()
  self.effects = app.media.effects()
  self.sound = app.media.sound()
  self.map = app.logic.map()
  self.hud = app.ui.hud.controller()

  self.event:on('game.quit', function(data)
    app.util.context:remove(ctx)
    app.util.context:add(app.context.menu)
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
