Goregous = class()

function Goregous:init()
  self.socket = (require('socket')).tcp()
  self.socket:settimeout(10)
  local ip = (env == 'local') and '127.0.0.1' or '67.0.161.178'
	ip = '127.0.0.1'
  local _, e = self.socket:connect(ip, 6060)
  if e then error('Can\'t connect to goregous') end
  self.messages = {}

	self:send({'version', love.system.getOS(), love.filesystem.read('version')})
	local bytes = tonumber(self.socket:receive('*l'))
	if bytes > 0 then
		local code = self.socket:receive(bytes)
		if love.system.getOS() == 'OS X' then
			local app = love.filesystem.getWorkingDirectory() .. '/groupGore.app'
			local file = io.open(app .. '.zip', 'w')
			file:write(code)
			file:close()
			print('wrote code to ' .. app .. '.zip')
			os.execute('unzip -o ' .. app .. '.zip')
			print('unzipped.')
			os.execute('rm ' .. app .. '.zip')
			print('removed zip.')
			os.execute('open ' .. app .. ' --args local')
			print('opening ' .. app)
		elseif love.system.getOS() == 'Windows' then
			local src = love.filesystem.getWorkingDirectory() .. '\\groupGore.exe'
			local dst = love.filesystem.getWorkingDirectory() .. '\\groupGore.exe.old'
			os.execute('move ' .. src .. ' ' .. dst)
			local file = io.open(love.filesystem.getWorkingDirectory() .. '\\groupGore.exe', 'w+')
			file:write(code)
			file:close()
			os.execute(src)
		end

		local bytes = tonumber(self.socket:receive('*l'))
		local data = self.socket:receive(bytes)
		love.filesystem.write('data.zip', data)

		--self.socket:close()
		--love.event.quit()

		--return
	end

	self.socket:settimeout(0)
end

function Goregous:update()
  while true do
    str = self.socket:receive('*l')
    if not str then break end
    local data = {}
    for word in string.gmatch(str, '([^,]+)') do
      table.insert(data, word)
    end
    table.insert(self.messages, data)
  end
end

function Goregous:quit()
  if self.socket then self.socket:close() end
end

function Goregous:send(data)
  self.socket:send(table.concat(data, ',') .. '\n')
end
