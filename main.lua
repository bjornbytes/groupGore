require 'require'

function love.load(arg)
  data.load()
  Context:add(Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})

env = arg[2] or 'release'
if env == 'test' then require 'test/runner' end
