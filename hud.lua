Hud = {}

function Hud:init()
	Hud.consoleOpen = false
	Hud.consoleInput = ''
	Hud.consoleResult = ''
	Hud.consoleResultAlpha = 0
	Hud.consoleFont = love.graphics.newFont('media/fonts/lucon.ttf', 12)
	Hud.consoleResultFont = love.graphics.newFont('media/fonts/BebasNeue.ttf', 40)
	
	Hud.health = {}
	Hud.health.canvas = love.graphics.newCanvas(160, 160)
	Hud.health.back = love.graphics.newImage('media/graphics/healthBack.png')
	Hud.health.glass = love.graphics.newImage('media/graphics/healthGlass.png')
	Hud.health.red = love.graphics.newImage('media/graphics/healthRed.png')
end

function Hud:update()
	self.consoleResultAlpha = math.min(self.consoleResultAlpha + (tickRate / .35), 1)

	if myId and Players:get(myId).active then
		self.health.canvas:clear()
		self.health.canvas:renderTo(function()
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.draw(self.health.red, 4, 13)
			love.graphics.setBlendMode('subtractive')
			love.graphics.setColor(255, 255, 255, 255)
			local p = Players:get(myId)
			love.graphics.arc('fill', 80, 80, 80, 0, 0 - ((2 * math.pi) * (1 - (p.health / p.maxHealth))))
			love.graphics.setBlendMode('alpha')
		end)
	end
end

function Hud:draw()
	love.graphics.reset()
	
	love.graphics.draw(self.health.back, 12, 12)
	love.graphics.draw(self.health.canvas, 4, 4)
	love.graphics.draw(self.health.glass, 0, 0)
	
	local p = Players:get(myId)
	if p and p.active then
		local wep, skl, pas = {}, {}, {}
		for i = 1, 5 do
			if p.slots[i].type == 'weapon' then wep[#wep + 1] = p.slots[i]
			elseif p.slots[i].type == 'skill' then skl[#skl + 1] = p.slots[i]
			else pas[#pas + 1] = p.slots[i] end
		end

		local ww = math.max(Hud.consoleFont:getWidth('weapon'), 52 * #wep)
		local sw = math.max(Hud.consoleFont:getWidth('skill'), 52 * #skl)
		local pw = math.max(Hud.consoleFont:getWidth('passive'), 52 * #pas)
		local w = 4 + ww + 16 + 4 + sw + 16 + 4 + pw
		
		local x = love.graphics.getWidth() / 2 - math.floor((w / 2) + .5)
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle('fill', x, 0, ww + 4, 52 + 8 + Hud.consoleFont:getHeight())
		love.graphics.setColor(80, 80, 80, 255)
		love.graphics.rectangle('line', x, -1, ww + 4, 52 + 8 + Hud.consoleFont:getHeight())
		for i = 1, #wep do
			if p.slots[p.input.slot.weapon] == wep[i] then love.graphics.setColor(255, 255, 255, 255)
			else love.graphics.setColor(80, 80, 80, 255) end
			love.graphics.rectangle('line', x + 4 + (52 * (i - 1)), 8 + Hud.consoleFont:getHeight(), 48, 48)
			love.graphics.setColor(80, 80, 80, 255)
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf('weapon', x + 4, 2, ww, 'center')
		x = x + (ww + 8 + 16)
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle('fill', x, 0, sw + 4, 52 + 8 + Hud.consoleFont:getHeight())
		love.graphics.setColor(80, 80, 80, 255)
		love.graphics.rectangle('line', x, -1, sw + 4, 52 + 8 + Hud.consoleFont:getHeight())
		for i = 1, #skl do
			if p.slots[p.input.slot.skill] == skl[i] then love.graphics.setColor(255, 255, 255, 255)
			else love.graphics.setColor(80, 80, 80, 255) end
			love.graphics.rectangle('line', x + 4 + (52 * (i - 1)), 8 + Hud.consoleFont:getHeight(), 48, 48)
			love.graphics.setColor(80, 80, 80, 255)
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf('skill', x + 4, 2, sw, 'center')
		x = x + (sw + 8 + 16)
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle('fill', x, 0, pw + 4, 52 + 8 + Hud.consoleFont:getHeight())
		love.graphics.setColor(80, 80, 80, 255)
		love.graphics.rectangle('line', x, -1, pw + 4, 52 + 8 + Hud.consoleFont:getHeight())
		for i = 1, #pas do
			love.graphics.rectangle('line', x + 4 + (52 * (i - 1)), 8 + Hud.consoleFont:getHeight(), 48, 48)
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf('passive', x + 4, 2, pw, 'center')
	end
	
	if self:classSelect() then
		love.graphics.setFont(self.consoleFont)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle('fill', 100, 100, 200, 100)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print('You must choose your class:', 110, 110)
		love.graphics.rectangle('line', 110, 125, 64, 64)
		love.graphics.print('BR00T', 120, 150)
	end
	
	if self.consoleOpen then
		love.graphics.setFont(self.consoleFont)
		love.graphics.setColor(24, 2, 35, 200)
		love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 128)
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.printf(self.consoleInput, 0, 128 - 4 - self.consoleFont:getHeight(), love.graphics.getWidth(), 'center')
		love.graphics.setFont(self.consoleResultFont)
		love.graphics.setColor(255, 255, 255, 200 * self.consoleResultAlpha)
		love.graphics.printf(self.consoleResult, 0, ((128 - self.consoleFont:getHeight()) / 2) - (self.consoleResultFont:getHeight() / 2), love.graphics.getWidth(), 'center')
	end
end

function Hud:mousepressed(x, y, button)
	
end

function Hud:mousereleased(x, y, button)
	if self:classSelect() and math.inside(x, y, 110, 125, 64, 64) and button == 'l' then
		Net:begin(Net.msgClass)
		   :write(1, 4)
		   :write(myId == 1 and 0 or 1, 1)
		   :send()
	end
end

function Hud:keypressed(key, code)
	if key == '`' then
		self.consoleOpen = not self.consoleOpen
		love.keyboard.setKeyRepeat(self.consoleOpen)
		return true
	elseif key == 'backspace' and self.consoleOpen then
		self.consoleInput = self.consoleInput:sub(0, -2)
		return true
	elseif key == 'return' and self.consoleOpen and #self.consoleInput > 0 then
		local str = self.consoleInput
		local chunk = loadstring(str)
		if not chunk then
			str = 'do return ' .. self.consoleInput .. ' end'
			chunk = loadstring(str)
			if not chunk then chunk = function() return 'error' end str = 'error' end
		end
		
		local suc, res = pcall(chunk)
		if str:sub(1, 2) ~= 'do' then res = 'kk' end
		if suc then
			self.consoleResult = tostring(res)
			Net:begin(Net.msgCmd)
		   :write(str)
		   :send()
		end
		self.consoleInput = ''
		self.consoleResultAlpha = 0
	elseif code >= 30 and self.consoleOpen then
		self.consoleInput = self.consoleInput .. string.char(code)
		return true
	elseif key == 'f5' then
		Players:reset()
		Net:begin(Net.msgCmd)
		   :write('Players:reset()')
		   :send()
		if self.consoleOpen == true then self.consoleOpen = false end
	end
end

function Hud:keyreleased(key, code)
	
end

function Hud:classSelect() return myId and not Players:get(myId).active end