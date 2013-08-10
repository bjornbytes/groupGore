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
  Players:mousepressed(...)
end

function Game.mousereleased(...)
  Players:mousereleased(...)
end

function Game.keypressed(...)
  Players:keypressed(...)
end

function Game.keyreleased(...)
  Players:keyreleased(...)
end