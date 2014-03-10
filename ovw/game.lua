Game = extend(Overwatch)

Game.tag = 'client'

function Game:init()
  self.event = Event()
  self.collision = Collision()
  
  self.net = self:addComponent(NetClient)
  self.buffs = self:addComponent(Buffs)
  self.players = self:addComponent(Players)
  self.spells = self:addComponent(Spells)
  self.particles = self:addComponent(Particles)
  self.view = self:addComponent(View)
  self.map = self:addComponent(Map)
  self.hud = self:addComponent(Hud)
end

function Game:draw()
  self.view:draw()
end

function Game:quit()
  --self.net:send(msgLeave)
  --self.net.host:flush()
end

--[[function Game:mousepressed(...)
  if self.players:mousepressed(...) then return end
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
end]]