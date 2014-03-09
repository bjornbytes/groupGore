return function(...)
  local function load(path)
    if love.filesystem.isDirectory(path) then
      for _, file in pairs(love.filesystem.getDirectoryItems(path)) do
        load(path .. '/' .. file)
      end
      
      return
    end
    
    if not love.filesystem.exists(path) then path = path .. '.lua' end
    
    if love.filesystem.exists(path) then
      require(path:gsub('%.lua', ''))
    end
  end

  for _, path in pairs({...}) do load(path) end
end