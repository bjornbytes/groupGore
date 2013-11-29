Game = {}

function Game:load()
  Players:init('client')
  Net:load('client')
  View:init()
  Hud:init()
end

function Game:unload()
  --
end

function Game:update()
  Net:update()
  Players:update()
  Spells:update()
  Particles:update()
  Map:update()
  Hud:update()
end

function Game:sync()
  Net:sync()
end

function Game:draw()
  View:draw()
end

function Game:quit()
  Net:send(msgLeave)
  Net.host:flush()
end

function Game.mousepressed(...)
  Players:mousepressed(...)
end

function Game.mousereleased(...)
  if Hud:mousereleased(...) then return
  elseif Players:mousereleased(...) then return end
end

function Game.keypressed(key)
  Players:keypressed(key)
  if key == 'escape' then love.event.quit() end
end

function Game.keyreleased(key)
  Players:keyreleased(key)
end

function Game.resize()
  View.resize()
end