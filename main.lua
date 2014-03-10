require('lib/require')('enet', 'lib/util', 'lib/ovw', 'lib', 'ovw', 'data/loader')

function love.load()
  setmetatable(love, {__index = Overwatch})
  setmetatable(love.handlers, {__index = function(t, k) print(k)return Overwatch.run(love, k) end})
  
  love:addComponent(Gorgeous)
  love:addComponent(Menu)

  table.each({'update', 'draw', 'sync'}, function(e) love[e] = Overwatch.run(love, e) end)

  data.load()
end