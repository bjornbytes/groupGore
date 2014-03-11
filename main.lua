require('lib/require')('enet', 'lib/util', 'lib', 'ovw', 'data/loader')

function love.load()
  data.load()

  Overwatch:add(Menu)
  gorgeous = Overwatch:add(Gorgeous)
  if not gorgeous.socket then gorgeous = nil end

  love.update = Overwatch.update
  love.draw = Overwatch.draw
  love.sync = Overwatch.sync
  love.quit = Overwatch.quit
  
  love.handlers = {}
  setmetatable(love.handlers, {__index = Overwatch})
end
