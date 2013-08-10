Game = {}

function Game:load()
  Net:load('client')
  Map:load('jungleCarnage')
end

function Game:update()
  Net:update()
  Players:update()
  Spells:update()
  View:update()
  Hud:update()
end

function Game:sync()
  --
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
  Net:begin(Net.msgLeave):send()
end

function Game.mousepressed(...)
  if Hud:mousepressed(...) then return
  elseif Players:mousepressed(...) then return end
end

function Game.mousereleased(...)
  if Hud:mousereleased(...) then return
  elseif Players:mousereleased(...) then return end
end

function Game.keypressed(...)
  if Hud:keypressed(...) then return
  elseif Players:keypressed(...) then return end
end

function Game.keyreleased(...)
  if Hud:keyreleased(...) then return
  elseif Players:keyreleased(...) then return end
end