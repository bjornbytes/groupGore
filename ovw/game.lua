Game = {}

function Game:load()
  MapOvw:load('jungleCarnage')
  Players:activate('main', Brute)
end

function Game:update()
  Players:update()
  Spells:update()
  View:update()
end

function Game:sync()
  --
end

function Game:draw()
  View:push()
  MapOvw:draw()
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