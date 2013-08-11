Server = {}

function Server:load()
  Net:load('server')
end

function Server:update()
  Net:update()
  Players:update()
end

function Server:sync()
  Players:sync()
end