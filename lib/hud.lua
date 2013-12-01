Hud = class()

local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return (love.window.getHeight() - ovw.view.margin * 2) * x end

function Hud:init()
	self.health = {}
	self.health.canvas = love.graphics.newCanvas(160, 160)
	self.health.back = love.graphics.newImage('media/graphics/healthBack.png')
	self.health.glass = love.graphics.newImage('media/graphics/healthGlass.png')
	self.health.red = love.graphics.newImage('media/graphics/healthRed.png')
	
	self.font = love.graphics.newFont('media/fonts/Ubuntu.ttf', h() * .0175)

	self.chatting = false
	self.chatMessage = ''
	self.chatLog = ''

	ovw.event:on(evtChat, self, function(self, data)
		self:updateChat(data.message)
	end)
end

function Hud:update()
	if myId and ovw.players:get(myId).active then
		self.health.canvas:clear()
		self.health.canvas:renderTo(function()
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.draw(self.health.red, 4, 13)
			love.graphics.setBlendMode('subtractive')
			love.graphics.setColor(255, 255, 255, 255)
			local p = ovw.players:get(myId)
			love.graphics.arc('fill', 80, 80, 80, 0, 0 - ((2 * math.pi) * (1 - (p.health / p.maxHealth))))
			love.graphics.setBlendMode('alpha')
		end)
	end
end

function Hud:draw()
	local g = love.graphics

	g.reset()
	g.setFont(self.font)
	
	if not myId then
		g.setColor(0, 0, 0)
		g.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
		g.setColor(255, 255, 255)
		local str = 'Connecting...'
		if tick > 5 / tickRate then
			str = str .. '\noshit'
		end
		if tick > 6 / tickRate then
			str = str .. ' oshit'
		end
		if tick > (6 / tickRate) + 5 then
			str = str .. ' oshit'
		end
		if tick > (6 / tickRate) + 10 then
			str = str .. ' oshit'
		end
		if tick > 10 / tickRate then
			str = str .. '\n'
			str = str .. string.rep('fuck', math.min(10, (tick - (10 / tickRate)) / 3))
		end
		g.printf(str, 0, math.floor(love.window.getHeight() / 2 - self.font:getHeight()), love.window.getWidth(), 'center')
		return
	end
	
	local s = math.min(1, h(.2) / 160)
	g.draw(self.health.back, 12 * s, 12 * s, 0, s, s)
	g.draw(self.health.canvas, 4 * s, 4 * s, 0, s, s)
	g.draw(self.health.glass, 0, 0, 0, s, s)
	
	local p = ovw.players:get(myId)
	if p and p.active then
		local wep, skl, pas = {}, {}, {}
		for i = 1, 5 do
			if p.slots[i].type == 'weapon' then wep[#wep + 1] = p.slots[i]
			elseif p.slots[i].type == 'skill' then skl[#skl + 1] = p.slots[i]
			else pas[#pas + 1] = p.slots[i] end
		end

		
		local height = (2 * h(.01)) + (5 * (h(.02) + self.font:getHeight()))
		local width = math.max(w(.12), self.font:getWidth('weapon name'))
		g.setFont(self.font)
		local yy = h(.5) - (height / 2)
		for i = 1, #wep do
			g.setColor(10, 10, 10)
			if p.slots[p.input.weapon] == wep[i] then g.setColor(40, 40, 40) end
			g.rectangle('fill', 0, yy, width, self.font:getHeight() + h(.02)) g.setColor(80, 80, 80)
			g.rectangle('line', 0 - .5, yy + .5, width, self.font:getHeight() + h(.02)) g.setColor(160, 160, 160)
			g.print(wep[i].name, 16, yy + h(.01))
			yy = yy + self.font:getHeight() + h(.02)
		end
	
		yy = yy + h(.01)
		for i = 1, #skl do
			g.setColor(10, 10, 10)
			if p.slots[p.input.skill] == skl[i] then g.setColor(40, 40, 40) end
			g.rectangle('fill', 0, yy, width, self.font:getHeight() + h(.02)) g.setColor(80, 80, 80)
			g.rectangle('line', 0 - .5, yy + .5, width, self.font:getHeight() + h(.02)) g.setColor(160, 160, 160)
			g.print(skl[i].name, 16, yy + h(.01))
			yy = yy + self.font:getHeight() + h(.02)
		end
		
		yy = yy + h(.01)
		for i = 1, #pas do
			g.setColor(10, 10, 10)
			g.rectangle('fill', 0, yy, width, self.font:getHeight() + h(.02)) g.setColor(80, 80, 80)
			g.rectangle('line', 0 - .5, yy + .5, width, self.font:getHeight() + h(.02)) g.setColor(160, 160, 160)
			g.print(pas[i].name, 16, yy + h(.01))
			yy = yy + self.font:getHeight() + h(.02)
		end
	end

	g.setColor(0, 0, 0, 180)
	local height = h(.2)
	if self.chatting then height = height + (self.font:getHeight() + 4.5) end
	g.rectangle('fill', 4, h() - (height + 4), w(.25), height)
	g.setFont(self.font)
	local yy = h() - 4
	if self.chatting then
		g.setColor(255, 255, 255, 60)
		g.line(4.5, h() - 4 - self.font:getHeight() - 4.5, 3 + w(.25), h() - 4 - self.font:getHeight() - 4.5)
		g.setColor(255, 255, 255, 100)
		g.print(self.chatMessage .. (self.chatting and '|' or ''), 4 + 2, math.floor(yy - self.font:getHeight() - 4.5 + 2 + .5))
		yy = yy - self.font:getHeight() - 4.5
	end

	g.setColor(255, 255, 255, 100)
	g.print(self.chatLog, 4 + 2, yy - (self.font:getHeight() * select(2, self.font:getWrap(self.chatLog, w(.25)))) - 2)

	if ovw.map.hud then ovw.map:hud() end

	g.setColor(255, 255, 255)
	local debug = love.timer.getFPS() .. 'fps'
	if ovw.net.server then debug = debug .. ', ' .. ovw.net.server:round_trip_time() .. 'ms' end
	g.print(debug, w() - self.font:getWidth(debug), h() - self.font:getHeight())

	if self:classSelect() then
		g.setFont(self.font)
		g.setColor(0, 0, 0)
		g.rectangle('fill', 100, 100, 200, 100)
		g.setColor(255, 255, 255)
		g.print('You must choose your class:', 110, 110)
		g.rectangle('line', 110, 125, 64, 64)
		g.print('BR00T', 120, 150)
	end
end

function Hud:mousereleased(x, y, button)
	if self:classSelect() and math.inside(x, y - ovw.view.margin, 110, 125, 64, 64) and button == 'l' then
		ovw.net:send(msgClass, {
			class = 1,
			team = myId > 1 and 1 or 0
		})
	end
end

function Hud:textinput(character)
	if self.chatting then self.chatMessage = self.chatMessage .. character end
end

function Hud:keypressed(key)
	if tick < 10 then return end

	if self.chatting then
		if key == 'backspace' then self.chatMessage = self.chatMessage:sub(1, -2)
		elseif key == 'return' then
			if #self.chatMessage > 0 then
				ovw.net:send(msgChat, {
					message = self.chatMessage
				})
			end
			self.chatting = false
			self.chatMessage = ''
			love.keyboard.setKeyRepeat(false)
		end
		return true
	else
		if key == 'return' then
			self.chatting = true
			self.chatMessage = ''
			love.keyboard.setKeyRepeat(true)
		end
	end
end

function Hud:updateChat(message)
	if #message > 0 then
		if #self.chatLog > 0 then self.chatLog = self.chatLog .. '\n' end
		self.chatLog = self.chatLog .. message
	end

	while self.font:getHeight() * select(2, self.font:getWrap(self.chatLog, w(.25))) > (h(.2) - 4) do
		self.chatLog = self.chatLog:sub(2)
	end
end

function Hud:keyreleased(key)
	if self.chatting then return true end
end

function Hud:classSelect() return myId and not ovw.players:get(myId).active end
