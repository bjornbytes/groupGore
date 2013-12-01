Game = class()

Game.tag = 'client'

function Game:load()
  self.event = Event()
  self.net = NetClient()
  self.view = View()
  self.collision = Collision()
  self.players = Players()
  self.spells = Spells()
  self.particles = Particles()
  self.map = Map()
  self.hud = Hud()
end

function Game:unload()
  --
end

function Game:update()
  self.net:update()
  self.players:update()
  self.spells:update()
  self.particles:update()
  self.map:update()
  self.view:update()
  self.hud:update()
end

function Game:sync()
  self.net:sync()
end

function Game:draw()
  self.view:draw()
end

function Game:quit()
  self.net:send(msgLeave)
  self.net.host:flush()
end

function Game:mousepressed(...)
  self.players:mousepressed(...)
end

function Game:mousereleased(...)
  if self.hud:mousereleased(...) then return
  elseif self.players:mousereleased(...) then return end
end

function Game:keypressed(key)
  if key == 'escape' then love.event.quit() end
  if self.hud:keypressed(key) then return
  elseif self.players:keypressed(key) then return end
end

function Game:keyreleased(key)
  self.players:keyreleased(key)
end

function Game:textinput(character)
  return self.hud:textinput(character)
end

function Game:resize()
  self.view:resize()
end