Typo = {}
Typo.fonts = {}
local oldSetFont = love.graphics.setFont

Typo.setFont = function(name, size)
	if type(name) == 'string' then
		Typo.setFontPixel(name, love.graphics.height(size / 100))
	else
		oldSetFont(name)
	end
end

Typo.setFontPixel = function(name, size)
	Typo.fonts[name] = Typo.fonts[name] or {}
	Typo.fonts[name][size] = Typo.fonts[name][size] or love.graphics.newFont('media/fonts/' .. name .. '.ttf', size)
	oldSetFont(Typo.fonts[name][size])
end

Typo.resize = function()
  table.clear(Typo.fonts)
end

love.graphics.setFont = Typo.setFont
love.graphics.setFontPixel = Typo.setFontPixel
