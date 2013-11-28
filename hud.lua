Hud = {}

function Hud:init()
	Hud.consoleOpen = false
	Hud.consoleInput = ''
	Hud.consoleResult = ''
	Hud.consoleResultAlpha = 0
	Hud.consoleFont = love.graphics.newFont('media/fonts/UbuntuMono.ttf', 12)
	Hud.consoleResultFont = love.graphics.newFont('media/fonts/Ubuntu.ttf', 40)
	
	Hud.health = {}
	Hud.health.canvas = love.graphics.newCanvas(160, 160)
	Hud.health.back = love.graphics.newImage('media/graphics/healthBack.png')
	Hud.health.glass = love.graphics.newImage('media/graphics/healthGlass.png')
	Hud.health.red = love.graphics.newImage('media/graphics/healthRed.png')
	
	Hud.font = love.graphics.newFont('media/fonts/Ubuntu.ttf', 12)
	Hud.biggerFont = love.graphics.newFont('media/fonts/Ubuntu.ttf', 16)
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
	love.graphics.setFont(self.font)
	
	if not myId then
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf('Connecting...', 0, love.window.getHeight() / 2 - self.font:getHeight(), love.window.getWidth(), 'center')
		return
	end
	
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
		
		love.graphics.setFont(self.biggerFont)
		local yy = 256
		for i = 1, #wep do
			love.graphics.setColor(10, 10, 10)
			if p.slots[p.input.weapon] == wep[i] then love.graphics.setColor(40, 40, 40) end
			love.graphics.rectangle('fill', 0, yy, 160, self.biggerFont:getHeight() + 16)
			love.graphics.setColor(80, 80, 80)
			love.graphics.rectangle('line', 0 - .5, yy + .5, 160, self.biggerFont:getHeight() + 16)
			love.graphics.setColor(160, 160, 160)
			love.graphics.print(wep[i].name, 16, yy + 8)
			yy = yy + self.biggerFont:getHeight() + 24
		end
		
		yy = yy + 24
		for i = 1, #skl do
			love.graphics.setColor(10, 10, 10)
			if p.slots[p.input.skill] == skl[i] then love.graphics.setColor(40, 40, 40) end
			love.graphics.rectangle('fill', 0, yy, 160, self.biggerFont:getHeight() + 16)
			love.graphics.setColor(80, 80, 80)
			love.graphics.rectangle('line', 0 - .5, yy + .5, 160, self.biggerFont:getHeight() + 16)
			love.graphics.setColor(160, 160, 160)
			love.graphics.print(skl[i].name, 16, yy + 8)
			yy = yy + self.biggerFont:getHeight() + 24
		end
		
		yy = yy + 24
		for i = 1, #pas do
			love.graphics.setColor(10, 10, 10)
			love.graphics.rectangle('fill', 0, yy, 160, self.biggerFont:getHeight() + 16)
			love.graphics.setColor(80, 80, 80)
			love.graphics.rectangle('line', 0 - .5, yy + .5, 160, self.biggerFont:getHeight() + 16)
			love.graphics.setColor(160, 160, 160)
			love.graphics.print(pas[i].name, 16, yy + 8)
			yy = yy + self.biggerFont:getHeight() + 24
		end
		love.graphics.setFont(self.font)
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
		Net:send(msgClass, {
			class = 1,
			team = myId > 1 and 1 or 0
		})
	end
end

function Hud:keypressed(key)
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
	elseif key:byte(1) >= 30 and self.consoleOpen then
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
