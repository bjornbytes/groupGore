data = {}
data.load = function()
  local function load(dir, type, fn)
    data[type] = {}
    local id = 1
    for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
      if file:match('%.lua$') then
        local obj = love.filesystem.load(dir .. '/' .. file)()
        obj = f.exe(fn, obj) or obj
        obj.id = id
        data[type][id] = obj
        data[type][obj.code] = obj
        id = id + 1
      end
    end
  end
  
  purple = 0
  orange = 1

  load('data/weapon', 'weapon', function(weapon)
    if weapon.image then weapon.image = love.graphics.newImage(weapon.image) end
  end)
  load('data/skill', 'skill')
  load('data/buff', 'buff', function(data)
    return table.merge(data, extend(Buff))
  end)
  load('data/spell', 'spell')
  load('data/class', 'class', function(class)
    --[[for name, sprite in pairs(class.sprites) do
      class.sprites[name] = love.graphics.newImage(sprite)
    end]]
    class.sprite = love.graphics.newImage(class.sprite)
  end)
  load('data/particle', 'particle', function(particle)
    for k, v in pairs(particle.initial) do
      if type(v) == 'string' and v:match('%.png') then
        particle.initial[k] = love.graphics.newImage(v)
      end
    end
  end)
  load('data/prop', 'prop')
  
  gG = {}
  gg = gG
  setmetatable(gg, {
    __index = function(t, k)
      if data[k] then return data[k] end
      if data.class[k] then return data.class[k] end
      if data.weapon[k] then return data.weapon[k] end
      if data.skill[k] then return data.skill[k] end
      if data.buff[k] then return data.buff[k] end
      if data.particle[k] then return data.particle[k] end
      
      return 'wat'
    end
  })
end
