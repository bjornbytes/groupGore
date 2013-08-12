Hud = {}

Hud.showConsole = false
Hud.consoleInput = ''

function Hud:update()
	
end

function Hud:draw()
	love.graphics.reset()
	
	if self:classSelect() then
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle('fill', 100, 100, 200, 100)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print('You must choose your class:', 110, 110)
		love.graphics.rectangle('line', 110, 125, 64, 64)
		love.graphics.print('BR00T', 120, 150)
	end
	
	if self.showConsole then
		love.graphics.setColor(24, 2, 35, 200)
		love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 128)
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.print(self.consoleInput, 2, 128 - 13)
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
		self.showConsole = not self.showConsole
		love.keyboard.setKeyRepeat(self.showConsole)
		return true
	elseif key == 'backspace' and self.showConsole then
		self.consoleInput = self.consoleInput:sub(0, -2)
		return true
	elseif code >= 30 and self.showConsole then
		self.consoleInput = self.consoleInput .. string.char(code)
		return true
	end
end

function Hud:keyreleased(key, code)
	
end

function Hud:classSelect() return myId and not Players:get(myId).active end