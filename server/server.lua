Server = {}

function Server:load()
  Net:load('server')
  Map:load('jungleCarnage')
end

function Server:update()
  Players:update()
  Spells:update()
end

function Server:sync()
  Players:sync()
end

function Server:quit()
	Net:begin(Net.msgLeave):write(0, 4):send(Net.clients)
end