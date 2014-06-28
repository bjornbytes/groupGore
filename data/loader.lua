data = {}
data.load = function()

  -- Media
  local function lookup(ext, fn)
    local function halp(s, k)
      local base = s._path .. '/' .. k
      if love.filesystem.exists(base .. ext) then
        s[k] = fn(base .. ext)
      elseif love.filesystem.isDirectory(base) then
        local t = {}
        t._path = base
        setmetatable(t, {__index = halp})
        s[k] = t
      end

      return rawget(s, k)
    end
    return halp
  end
  
  data.media = {}
  data.media.graphics = setmetatable({_path = 'data/media/graphics'}, {__index = lookup('.png', love.graphics.newImage)})
  data.media.shaders = setmetatable({_path = 'data/media/shaders'}, {__index = lookup('.shader', love.graphics.newShader)})
  data.media.sounds = setmetatable({_path = 'data/media/sounds'}, {__index = lookup('.ogg', love.audio.newSource)})

  -- Data
  local function load(dir, type, fn)
    data[type] = {}
    local id = 1
    for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
      if file:match('%.lua$') and not file:match('^%.') then
        local obj = love.filesystem.load(dir .. '/' .. file)()
        obj = f.exe(fn, obj) or obj
        obj.id = id
        data[type][id] = obj
        data[type][obj.code] = obj
        id = id + 1
      end
    end
  end
  
  load('data/weapon', 'weapon')
  load('data/skill', 'skill')
  load('data/buff', 'buff')
  load('data/spell', 'spell')
  load('data/class', 'class')
  load('data/particle', 'particle')
  load('data/prop', 'prop')
  load('data/effect', 'effect')
  load('data/weather', 'weather')
end
