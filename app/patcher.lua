local Patcher = class()

function Patcher:load()
  local fs = love.filesystem
  local version = fs.exists('version') and fs.read('version'):match('%w+') or ''
  local os = love.system.getOS()
  if os == 'OS X' then os = 'OSX' end

  local code, gameData = app.goregous:patch(version, os)
  if false and code and f.exe(self['patch' .. os], self, code, gameData) then
    love.event.quit()
  else
    app.core.context:remove(self)
    app.core.context:add(app.menu.context)
  end
end

function Patcher:patchWindows(code, data)
  local src = love.filesystem.getWorkingDirectory() .. '\\groupGore.exe'
  local dst = love.filesystem.getWorkingDirectory() .. '\\groupGore.exe.old'
  os.execute('move ' .. src .. ' ' .. dst)

  local file = io.open(love.filesystem.getWorkingDirectory() .. '\\groupGore.exe', 'w')
  file:write(code)
  file:close()

  love.filesystem.write('data.zip', data)

  os.execute(src)
end

function Patcher:patchOSX(code, data)
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

return Patcher
