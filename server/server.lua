Server = {}

function Server:load()
	Event:init('server')
	Players:init('server')
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
