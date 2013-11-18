Server = {}

function Server:load()
  Net:load('server')
  Map:load('jungleCarnage')
end

function Server:update()
	Net:update()
  Players:update()
  Spells:update()
end

function Server:sync()
  Net:sync()
end

function Server:quit()
	-- Tell people you're leaving.
end

on(evtJoin, Server, function(self, data)
	print(data.username)
end)