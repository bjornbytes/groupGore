Bitstream = class()

function Bitstream:init(str)
  self.str = str or ''
  self.byte = nil
  self.byteLen = nil
end

function Bitstream:write(data, kind)
  if not kind or kind == 0 or type(kind) == 'string' then
    if self.byte then
      self.str = self.str .. string.char(self.byte)
      self.byte = nil
      self.byteLen = nil
    end
    if #data > 0 then self.str = self.str .. string.char(#data) .. data end
    return self
  end
  
  local n = kind
  if n then
    local idx = 0
    repeat
      if not self.byte then self.byte = 0 self.byteLen = 0 end
      local numWrite = math.min(n, (7 - self.byteLen) + 1)
      local toWrite = byte.extract(data, idx, idx + (numWrite - 1))
      self.byte = byte.insert(self.byte, toWrite, self.byteLen, self.byteLen + (numWrite - 1))
      self.byteLen = self.byteLen + numWrite
      
      if self.byteLen == 8 then
        self.str = self.str .. string.char(math.max(self.byte, 0))
        self.byte = nil
        self.byteLen = nil
      end
      
      n = n - numWrite
      idx = idx + numWrite
    until n == 0
    
    return self
  end
  
  return self
end

function Bitstream:read(n)
  if type(n) == 'string' or n <= 0 then
    if self.byte then
      self.str = self.str:sub(2)
      self.byte = nil
      self.byteLen = nil
    end
    n = self.str:byte(1)
    self.str = self.str:sub(2)
    local res = self.str:sub(1, n)
    self.str = self.str:sub(n + 1)
    return res
  else
    local x = 0
    local idx = 0
    while n > 0 do
      if not self.byte then self.byte = self.str:byte(1) or 0 self.byteLen = 0 end
      local numRead = math.min(n, (7 - self.byteLen) + 1)
      x = x + (byte.extract(self.byte, self.byteLen, self.byteLen + (numRead - 1)) * (2 ^ idx))
      self.byteLen = self.byteLen + numRead
      
      if self.byteLen == 8 then
        self.str = self.str:sub(2)
        self.byte = nil
        self.byteLen = nil
      end
      
      n = n - numRead
      idx = idx + numRead
    end
    
    return x
  end
end