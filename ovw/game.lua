Game = {}

function Game:load()
  Net:load('client')
  Map:load('jungleCarnage')
  Players:activate('main', data.class.brute)
end

function Game:update()
  Net:update()
  Players:update()
  Spells:update()
  View:update()
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