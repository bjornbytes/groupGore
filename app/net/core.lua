local Net = class()

Net.events = {
  join = 1,
  leave = 2,
  class = 3,
  sync = 4,
  fire = 5,
  damage = 6,
  dead = 7,
  spawn = 8,
  chat = 9,
  prop = 10
}

Net.messages = {
  join  = 11,
  leave = 12,
  snapshot = 13,
  class = 14,
  input = 15,
  chat = 16
}

function Net:init()
  self.inStream = app.net.stream()
  self.outStream = app.net.stream()
end

function Net:listen(port)
  self.host = enet.host_create(port and '*:' .. port or nil, 16, 2)
  if not self.host then error('Error creating the connection') end
  --self.host:compress_with_range_coder()
end

function Net:connectTo(ip, port)
  if not self.host then self:listen() end
  local peer = self.host:connect(ip .. ':' .. port, 2)
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
  self.outStream:write(msg, '5bits')
  self.outStream:pack(data, self.signatures[msg])
end

function Net:unpack()
  local msg = self.inStream:read('5bits')
  if not self.other.signatures[msg] then return false end
  return msg, self.inStream:unpack(self.other.signatures[msg])
end

return Net
