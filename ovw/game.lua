Game = {}

function Game:load()
  Net:load('client')
  Hud:init()
end

function Game:unload()
  --
end

function Game:update()
  Net:update()
  Players:update()
  Spells:update()
  View:update()
  Hud:update()
end

function Game:sync()
  Net:sync()
end

function Game:draw()
  View:push()
  Map:draw()
  Players:draw()
  Spells:draw()
  View:pop()
  Hud:draw()
end

function Game:quit()
  -- Net:begin(Net.msgLeave):send()
end

function Game.mousepressed(...)
  if Hud:mousepressed(...) then return
  elseif Players:mousepressed(...) then return end
end

function Game.mousereleased(...)
  if Hud:mousereleased(...) then return
  elseif Players:mousereleased(...) then return end
end

function Game.keypressed(key)
  if Hud:keypressed(key) then return
  elseif Players:keypressed(key) then return end
end

function Game.keyreleased(key)
  if Hud:keyreleased(key) then return
  elseif Players:keyreleased(key) then return end
end
