return function(...)
  local function load(path)
    if love.filesystem.isDirectory(path) then
      for _, file in pairs(love.filesystem.getDirectoryItems(path)) do
        load(path .. '/' .. file)
      end
      
      return
    end
    
    if not love.filesystem.exists(path) and love.filesystem.exists(path .. '.lua') then path = path .. '.lua' end
    
    require(path:gsub('%.lua', ''))
  end

  for _, path in pairs({...}) do load(path) end
end