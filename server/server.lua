Server = {}

function Server:load()
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
	if Net.host then
		for i = 1, 16 do
			if Net.host:get_peer(i) then Net.host:get_peer(i):disconnect_now() end
		end
	end
end
