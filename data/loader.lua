data = {}
data.load = function()
	love.filesystem.unmount('data.zip')
	if love.filesystem.exists('data.zip') then love.filesystem.mount('data.zip', 'data') end

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
  data.media.refresh = function(k)
    if k == 'graphics' then data.media.graphics = setmetatable({_path = 'data/media/graphics'}, {__index = lookup('.png', love.graphics.newImage)})
    elseif k == 'shaders' then data.media.shaders = setmetatable({_path = 'data/media/shaders'}, {__index = lookup('.shader', love.graphics.newShader)})
    elseif k == 'sounds' then data.media.sounds = setmetatable({_path = 'data/media/sounds'}, {__index = lookup('.ogg', love.audio.newSource)}) end
  end
  data.media.refresh('graphics')
  data.media.refresh('shaders')
  data.media.refresh('sounds')

  -- Data
  local function load(dir, type, fn)
    local id = 1
    local function halp(dir, dst)
      for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
        path = dir .. '/' .. file
        if love.filesystem.isDirectory(path) then
          dst[file] = {}
          halp(path, dst[file])
        elseif file:match('%.lua$') and not file:match('^%.') then
          local obj = love.filesystem.load(path)()
          obj = f.exe(fn, obj) or obj
          obj.id = id
          data[type][id] = obj
          dst[obj.code] = obj
          id = id + 1
        end
      end
    end

    data[type] = {}
    halp(dir, data[type])
  end
  
  load('data/weapon', 'weapon')
  load('data/skill', 'skill')
  load('data/buff', 'buff')
  load('data/spell', 'spell')
  load('data/class', 'class')
  load('data/mods', 'mods')
  load('data/particle', 'particle')
  load('data/prop', 'prop')
  load('data/effect', 'effect')
  load('data/weather', 'weather')
  load('data/gooey', 'gooey')
end
