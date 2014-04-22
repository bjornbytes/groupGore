Typo = {}
Typo.fonts = {}
local setFont = love.graphics.setFont

love.graphics.setFont = function(name, size)
  if type(name) ~= 'string' then return setFont(name) end

  Typo.fonts[name] = Typo.fonts[name] or {}
  Typo.fonts[name][size] = Typo.fonts[name][size] or love.graphics.newFont('data/media/fonts/' .. name .. '.ttf', size)
  setFont(Typo.fonts[name][size])
end

Typo.resize = function()
  table.clear(Typo.fonts)
end
