Gorgeous = class()

Gorgeous.msgLogin = 1

Gorgeous.signatures = {
  [Gorgeous.msgLogin] = {{'username', 'string'}, {'password', 'string'}}
}

Gorgeous.otherSignatures = {
  [Gorgeous.msgLogin] = {{'success', 'bool'}}
}

Gorgeous.receive = {}
Gorgeous.receive[Gorgeous.msgLogin] = function(self, data)
  if data.success then print('Login was successful!')
  else print('Login was not successful!') end
end

function Gorgeous:load()
  self.socket = require('socket').connect('localhost', 6060)
  
  if not self.socket then Overwatch:remove(self) return end

  self.socket:settimeout(0)

  self.inStream = Stream()
  self.outStream = Stream()

  self:send(Gorgeous.msgLogin, {
    username = 'tie372',
    password = 'asdf'
  })
end

function Gorgeous:unload()
  if self.socket then self.socket:close() end
end

function Gorgeous:update()
  while true do
    local data = self.socket:receive()
    if not data then break end

    self.inStream:clear()
    self.inStream.str = data
    local msg, data = self:unpack()
    if self.receive[msg] then self.receive[msg](self, data) end
  end
end

function Gorgeous:send(msg, data)
  self.outStream:clear()
  self:pack(msg, data)
  self.socket:send(tostring(self.outStream))
end

function Gorgeous:pack(msg, data)
  self.outStream:write(msg, '4bits')
  self.outStream:pack(data, self.signatures[msg])
end

function Gorgeous:unpack()
  local msg = self.inStream:read('4bits')
  if msg == 0 or not self.otherSignatures[msg] then return false end
  return msg, self.inStream:unpack(self.otherSignatures[msg])
end