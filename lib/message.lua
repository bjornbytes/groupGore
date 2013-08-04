Message = class()

function Message:init(id)
  self.id = id
  self.body = Bitstream()
  if type(id) == 'string' then self:parse(id) end
  
  setmetatable(self, table.merge({
    __tostring = function(t)
      t.body:write('')
      return string.char(t.id) .. string.char(#t.body.str) .. t.body.str
    end
  }, table.copy(getmetatable(self))))
end

function Message:write(data, kind)
  self.body:write(data, kind)
  return self
end

function Message:append(stream)
  self.body:write('')
  stream:write('')
  self.body.str = self.body.str .. stream.str
  return self
end

function Message:read(...)
  local t = {}
  for _, kind in pairs({...}) do
    t[#t + 1] = self.body:read(kind)
  end
  return unpack(t)
end

function Message:parse(str)
  local id, size = str:byte(1, 2)
  self.id = id
  self.body = Bitstream(str:sub(3, 3 + size))
  return self
end

function Message:send(sender)
  sender:send(self)
end