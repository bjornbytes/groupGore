Typo = {}
Typo.fonts = {}
local setFont = love.graphics.setFont

Typo.font = function(name, size)
  if not name then
    Typo.fonts.default[size] = Typo.fonts.default[size] or love.graphics.newFont(size)
    return Typo.fonts.default[size]
  end
  
  if Typo.fonts[name] and Typo.fonts[name][size] then return Typo.fonts[name][size] end
  Typo.fonts[name] = Typo.fonts[name] or {}
  Typo.fonts[name][size] = Typo.fonts[name][size] or love.graphics.newFont('data/media/fonts/' .. name .. '.ttf', size)
  return Typo.fonts[name][size]
end

love.graphics.setFont = function(name, size)
  if type(name) ~= 'string' then return setFont(name) end

  setFont(Typo.font(name, size))
end

Typo.resize = function()
  table.clear(Typo.fonts)
end
