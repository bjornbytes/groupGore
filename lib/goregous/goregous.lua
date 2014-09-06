Goregous = class()

function Goregous:init()
  self.socket = (require('socket')).tcp()
  self.socket:settimeout(10)
  local ip = (env == 'local') and '127.0.0.1' or '0.0.0.0'
  local _, e = self.socket:connect(ip, 6060)
  if e then error('Can\'t connect to goregous') end
  self.messages = {}

  if love.filesystem.exists('version') or env == 'release' then
    self:patch()
  end

  if self.socket then self.socket:settimeout(0) end
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

function Goregous:patch()
  local version = love.filesystem.read('version'):match('%w')
  local os = love.system.getOS()
  if os == 'OS X' then os = 'OSX' end

  self:send({'version', version, os})

  local bytes = tonumber(self.socket:receive('*l'))
  if bytes == 0 then return false end
  local code, data, patched
  
  code = self.socket:receive(bytes)
  data = self.socket:receive(tonumber(socket:receive('*l')))
  patched = self['patch' .. os](self, code, data)

  if patched then
    self.socket:close()
    love.event.quit()
  end
end

function Goregous:patchWindows(code, data)
  local src = love.filesystem.getWorkingDirectory() .. '\\groupGore.exe'
  local dst = love.filesystem.getWorkingDirectory() .. '\\groupGore.exe.old'
  os.execute('move ' .. src .. ' ' .. dst)

  local file = io.open(love.filesystem.getWorkingDirectory() .. '\\groupGore.exe', 'w')
  file:write(code)
  file:close()

  love.filesystem.write('data.zip', data)

  os.execute(src)
end

function Goregous:patchOSX(code, data)
  local app = love.filesystem.getWorkingDirectory() .. '/groupGore.app'
  local zip = app .. '.zip'

  local file = io.open(zip, 'w')
  file:write(code)
  file:close()

  love.filesystem.write('data.zip', data)

  os.execute('unzip -o ' .. zip)
  os.execute('rm ' .. zip)
  os.execute('open ' .. app .. ' --args local')
end

function Goregous:patchLinux()
  --
end
