Hud = {}

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
end

function Hud:mousepressed(x, y, button)
	
end

function Hud:mousereleased(x, y, button)
	if self:classSelect() and math.inside(x, y, 110, 125, 64, 64) and button == 'l' then
		print('Smart choice')
		Net:begin(Net.msgClass)
		   :write(1, 4)
		   :write(0, 1)
		   :send()
	end
end

function Hud:keypressed(x, y, button)
	
end

function Hud:keyreleased(x, y, button)
	
end

function Hud:classSelect() return myId and not Players:get(myId).active end