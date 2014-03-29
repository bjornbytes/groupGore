local function load(dir)
  for _, file in pairs(love.filesystem.getDirectoryItems(dir)) do
    local path = dir .. '/' .. file
    if string.find(path, '%.lua') and not string.find(path, '%..+%.lua') then
      require(path:gsub('%.lua', ''))
    end
  end
  
  if love.filesystem.exists(dir .. '.lua') then require(dir) end
end

require 'enet'
load 'lib/lutil'
load 'lib'
load 'lib/editor'
load 'lib/hud'
load 'lib/menu'
load 'lib/gooey'
load 'ovw'
load 'data/loader'
