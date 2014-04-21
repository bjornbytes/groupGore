require 'require'

function love.load(arg)  
  data.load()
  Context:add(Menu)
end

love.update = Context.update
love.draw = Context.draw
love.sync = Context.sync
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})

if arg[2] == 'test' then require 'test/test' end
