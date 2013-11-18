NetServer = {}

NetServer.signatures = {}
NetServer.signatures[evtJoin] = {{'tick', '16bits'}, {'map', 'string'}}
NetServer.signatures[evtLeave] = {{'idx', '4bits'}}

function NetServer:activate()
	self:listen(6061)
end

function NetServer:connect(peer)
	remotePeer = peer
end