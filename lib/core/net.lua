Net = class()

evtJoin = 1
evtLeave = 2
evtClass = 3
evtSync = 4
evtFire = 5
evtDamage = 6
evtDead = 7
evtSpawn = 8
evtChat = 9
evtProp = 10

msgJoin  = 11
msgLeave = 12
msgSnapshot = 13
msgClass = 14
msgInput = 15
msgChat = 16

function Net:init()
  self.inStream = Stream()
  self.outStream = Stream()
end

function Net:listen(port)
  self.host = enet.host_create(port and '*:' .. port or nil)
  if not self.host then error('Error creating the connection') end
end

function Net:connectTo(ip, port)
  if not self.host then self:listen() end
  local peer = self.host:connect(ip .. ':' .. port)
  peer:timeout(0, 0, 3000)
end

function Net:update()
  while true do
    if not self.host then break end
    local event = self.host:service()
    if not event then break end
    
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
  self.outStream:write(msg - 1, '4bits')
  self.outStream:pack(data, self.signatures[msg])
end

function Net:unpack()
  local msg = self.inStream:read('4bits') + 1
  if msg == 0 or not self.other.signatures[msg] then return false end
  return msg, self.inStream:unpack(self.other.signatures[msg])
end
