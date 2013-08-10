Hud = {}

function Hud:update()
	if self:classSelect() then
		if math.inside(love.mouse.getX(), love.mouse.getY(), 110, 125, 64, 64) and love.mouse.isDown('l') then
			print('Smart choice')
		end
	end
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

function Hud:classSelect() return myId and not Players:get(myId).active end