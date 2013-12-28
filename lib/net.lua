Net = class()

evtJoin  = 1
evtLeave = 2
evtClass = 3
evtSync = 4
evtFire = 5
evtDamage = 6
evtDead = 7
evtSpawn = 8
evtChat = 9

msgJoin  = 10
msgLeave = 11
msgSnapshot = 12
msgClass = 13
msgInput = 14
msgChat = 15

function Net:init()
  self.inStream = Stream()
  self.outStream = Stream()
end

function Net:listen(port)
  self.host = enet.host_create(port and '*:' .. port or nil)
end

function Net:connectTo(ip, port)
  if not self.host then self:listen() end
  self.host:connect(ip .. ':' .. port)
end

function Net:update()
  if not self.host then return end
  while true do
    local event = self.host:service()
    if not event then break end
    
    event.pid = self.peerToPlayer and self.peerToPlayer[event.peer] or event.peer:index()
    
    if event.type == 'receive' then
      self.inStream:clear()
      self.inStream.str = event.data

      repeat
        event.msg, event.data = self:unpack()
        ;(self.receive[event.msg] or self.receive.default)(self, event)
      until not event.msg
    else
      f.exe(self[event.type], self, event)
    end
  end
end

function Net:pack(msg, data)
  self.outStream:write(msg, '4bits')
  self.outStream:pack(data, self.signatures[msg])
end

function Net:unpack()
  local msg = self.inStream:read('4bits')
  if msg == 0 or not self.other.signatures[msg] then return false end
  return msg, self.inStream:unpack(self.other.signatures[msg])
end