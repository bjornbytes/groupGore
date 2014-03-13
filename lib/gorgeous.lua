Gorgeous = class()

Gorgeous.msgLogin = 1
Gorgeous.msgServerList = 2
Gorgeous.msgServerCreate = 3
Gorgeous.msgServerDelete = 4
Gorgeous.msgServerHeartbeat = 5
Gorgeous.msgMatchmake = 6

Gorgeous.signatures = {
  [Gorgeous.msgLogin] = {{'username', 'string'}, {'password', 'string'}},
  [Gorgeous.msgServerList] = {},
  [Gorgeous.msgServerCreate] = {{'name', 'string'}},
  [Gorgeous.msgServerDelete] = {},
  [Gorgeous.msgServerHeartbeat] = {},
  [Gorgeous.msgMatchmake] = {}
}

Gorgeous.otherSignatures = {
  [Gorgeous.msgLogin] = {{'success', 'bool'}},
  [Gorgeous.msgServerList] = {{'servers', {
    {'name', 'string'},
    {'ip', 'string'}
  }}},
  [Gorgeous.msgServerCreate] = {{'success', 'bool'}},
  [Gorgeous.msgMatchmake] = {{'ip', 'string'}, {'name', 'string'}}
}

Gorgeous.receive = {}
Gorgeous.receive[Gorgeous.msgLogin] = function(self, data)
  print(data.success)
end

function Gorgeous:load()
  self.socket = require('socket').tcp()
  self.socket:settimeout(1)
  local _, err = self.socket:connect('127.0.0.1', 6060)--'107.4.63.70', 6060)
  
  if err then
    print('Can\'t connect to Gorgeous.  Things are looking pretty ugly.')
    Overwatch:remove(self)
    self.socket = nil
    return
  end

  self.socket:settimeout(0)

  self.inStream = Stream()
  self.outStream = Stream()

  self.seq = 1
  self.callbacks = {}
end

function Gorgeous:unload()
  if self.socket then self.socket:close() end
end

function Gorgeous:update()
  while self.socket do
    local data = self.socket:receive()
    if not data then break end

    self.inStream:clear()
    self.inStream.str = data
    local seq, msg, data = self:unpack()
    f.exe(self.callbacks[seq], data)
    self.callbacks[seq] = nil
  end
end

function Gorgeous:send(msg, data, cb)
  if not gorgeous then return end

  self.outStream:clear()
  self.outStream:write(self.seq, '8bits')
  self:pack(msg, data)
  self.socket:send(tostring(self.outStream))

  self.callbacks[self.seq] = cb
  self.seq = (self.seq % 255) + 1
end

function Gorgeous:pack(msg, data)
  self.outStream:write(msg, '4bits')
  self.outStream:pack(data, self.signatures[msg])
end

function Gorgeous:unpack()
  local seq = self.inStream:read('8bits')
  local msg = self.inStream:read('4bits')
  if msg == 0 or not self.otherSignatures[msg] then return false end
  return seq, msg, self.inStream:unpack(self.otherSignatures[msg])
end