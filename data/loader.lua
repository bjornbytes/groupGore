data = {}
data.load = function()
  local function load(dir, type, fn)
    data[type] = {}
    local id = 1
    for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
      if file:match('%.lua') then
        local obj = love.filesystem.load(dir .. '/' .. file)()
        obj.id = id
        data[type][id] = obj
        data[type][obj.code] = obj
        id = id + 1
        f.exe(fn, obj)
      end
    end
  end
  
  purple = 0
  orange = 1

  load('data/weapon', 'weapon')
  load('data/skill', 'skill')
  load('data/buff', 'buff')
  load('data/spell', 'spell')
  load('data/class', 'class', function(class)
    for name, sprite in pairs(class.sprites) do
      class.sprites[name] = love.graphics.newImage(sprite)
    end
  end)
  
  gG = {}
  gg = gG
  setmetatable(gg, {
    __index = function(t, k)
      if data[k] then return data[k] end
      if data.class[k] then return data.class[k] end
      if data.weapon[k] then return data.weapon[k] end
      if data.skill[k] then return data.skill[k] end
      if data.buff[k] then return data.buff[k] end
      
      return 'wat'
    end
  })
end
