Hud = {}

Hud.consoleOpen = false
Hud.consoleInput = ''
Hud.consoleResult = ''
Hud.consoleResultAlpha = 0
Hud.consoleFont = love.graphics.newFont('media/fonts/lucon.ttf', 12)
Hud.consoleResultFont = love.graphics.newFont('media/fonts/BebasNeue.ttf', 40)

function Hud:update()
	self.consoleResultAlpha = math.min(self.consoleResultAlpha + (tickRate / .35), 1)
end

function Hud:draw()
	love.graphics.reset()
	
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