Game = class()

Game.tag = 'client'

function Game:load()
  self.event = Event()
  self.net = NetClient()
  self.view = View()
  self.collision = Collision()
  self.players = Players()
  self.spells = Spells()
  self.buffs = Buffs()
  self.particles = Particles()
  self.sound = Sound()
  self.map = Map()
  self.hud = Hud()
end

function Game:update()
  self.net:update()
  self.buffs:update()
  self.players:update()
  self.spells:update()
  self.particles:update()
  self.map:update()
  self.view:update()
  self.hud:update()
end

function Game:draw()
  self.view:draw()
end

function Game:quit()
  self.net:send(msgLeave)
  self.net.host:flush()
end

function Game:mousepressed(...) self.hud:mousepressed(...) end 
function Game:mousereleased(...) self.hud:mousereleased(...) end 
function Game:keypressed(key) self.hud:keypressed(key) end 
function Game:keyreleased(key) self.hud:keyreleased(key) end 
function Game:textinput(character) self.hud:textinput(character) end

function Game:resize()
  self.view:resize()
  Typo:resize()
end