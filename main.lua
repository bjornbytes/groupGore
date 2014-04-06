require 'require'

function love.load(arg)  
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
  
  if arg[2] == 'test' then require 'test/test' end
end
