Stream = {}

function Stream:create(str)
  local stream = {}
  stream.str = str or ''
  stream.byte = nil
  stream.byteLen = nil
  setmetatable(stream, {
    __index = Stream,
    __tostring = Stream.truncate
  })
  return stream
end

function Stream:truncate()
	if self.byte then
		self.str = self.str .. string.char(self.byte)
		self.byte = nil
		self.byteLen = nil
	end

	return self.str
end

function Stream:clear()
	self.str = ''
	self.byte = nil
	self.byteLen = nil
end

function Stream:write(x, sig)
	if sig == 'string' then self:writeString(x)
	elseif sig == 'bool' then self:writeBoolean(x)
	elseif sig == 'float' then self:writeFloat(x)
	else
		local n = sig:match('(%d+)bit')
		self:writeBits(x, n)
	end
end

function Stream:writeString(string)
	self:truncate()
	string = tostring(string)
	self.str = self.str .. string.char(#string) .. string
end

function Stream:writeBool(bool)
	local x = bool and 1 or 0
	self:writeBits(x, 1)
end

function Stream:writeFloat(float)
	self:writeString(float)
end

function Stream:writeBits(x, n)
	local idx = 0
	repeat
		if not self.byte then self.byte = 0 self.byteLen = 0 end
		local numWrite = math.min(n, (7 - self.byteLen) + 1)
		local toWrite = byte.extract(x, idx, idx + (numWrite - 1))
		self.byte = byte.insert(self.byte, toWrite, self.byteLen, self.byteLen + (numWrite - 1))
		self.byteLen = self.byteLen + numWrite
		
		if self.byteLen == 8 then
			self.str = self.str .. string.char(self.byte)
			self.byte = nil
			self.byteLen = nil
		end
		
		n = n - numWrite
		idx = idx + numWrite
	until n == 0
end

function Stream:read(kind)
	if kind == 'string' then return self:readString()
	elseif kind == 'bool' then return self:readBool()
	elseif kind == 'float' then return self:readFloat()
	else
		local n = tonumber(kind:match('(%d+)bit'))
		return self:readBits(n)
	end
end

function Stream:readString()
	if self.byte then
		self.str = self.str:sub(2)
		self.byte = nil
		self.byteLen = nil
	end
	local len = self.str:byte(1)
	self.str = self.str:sub(2)
	local res = self.str:sub(1, len)
	self.str = self.str:sub(len + 1)
	return res
end

function Stream:readBool()
	return self:readBits(1) > 0
end

function Stream:readFloat()
	return tonumber(self:readString())
end

function Stream:readBits(n)
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

setmetatable(Stream, {
	__call = Stream.create
})
