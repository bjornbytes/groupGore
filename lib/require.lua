Require = class()

function Require:init(...)
  self.files = {}
  
  local function load(path)
    if love.filesystem.isDirectory(path) then
      return table.each(love.filesystem.getDirectoryItems(path), function(file)
        load(path .. '/' .. file)
      end)
    end
    
    if not love.filesystem.exists(path) then path = path .. '.lua' end
    if love.filesystem.exists(path) and not table.has(self.files, items) then
      local file = {filename = path, modified = love.filesystem.getLastModified(path)}
      table.insert(self.files, file)
      require(path:gsub('%.lua', ''))
    end
  end

  table.each({...}, load)
  
  print(data)
end

function Require:update()
  table.each(self.files, function(file)
    if file.modified < love.filesystem.getLastModified(file.filename) then
      self:reload(file)
      love.load()
    end
  end)
end

function Require:reload(file)
  file.modified = love.filesystem.getLastModified(file.filename)
  local success, chunk, result
  success, chunk = pcall(love.filesystem.load, file.filename)
  if success then
    success, result = pcall(chunk)
    if not success then print('file modification caused error') end
  else
    print('love.filesystem.load failed')
  end
end