Server = {}

function Server:load()
  Net:load('server')
  Map:load('jungleCarnage')
end

function Server:update()
  Net:update()
  Players:update()
end

function Server:sync()
  Players:sync()
end