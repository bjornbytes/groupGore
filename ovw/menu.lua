Menu = {}

local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return love.window.getHeight() * x end

function Menu:load()
  self.font = love.graphics.newFont('/media/fonts/Ubuntu.ttf', 16)
  self.titleFont = love.graphics.newFont('/media/fonts/Ubuntu.ttf', 32)
  
  self.bg = love.graphics.newImage('/media/graphics/menu/bgMenu.jpeg')
  
  self.page = 'login'
  self.focused = nil

  self.ip = '127.0.0.1'
  self.username = 'username'
  self.password = 'password'
  self.ipDefault = nil
  self.usernameDefault = self.username
  self.passwordDefault = self.password
  
  love.window.setMode(800, 600, {resizable = true, minwidth = 640, minheight = 480})
  love.keyboard.setKeyRepeat(true)
end

function Menu:unload()
  self.bg = nil
end

function Menu:draw()
  love.graphics.setColor(50, 50, 55)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.bg, 0, 0, 0, love.window.getWidth() / self.bg:getWidth(), love.window.getHeight() / self.bg:getHeight())
  
  if self.page == 'login' then
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(108, 89, 128)
    love.graphics.print('g', 20, 16)
    love.graphics.setColor(140, 107, 84)
    love.graphics.print('G', 20 + self.titleFont:getWidth('g'), 16)
    
    love.graphics.setFont(self.font)
    local fh = self.font:getHeight()
    local ih = math.max(40, fh)
    local iw = math.min(w(.3), 240)
    love.graphics.setColor(30, 30, 30)
    love.graphics.rectangle('fill', w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih)
    love.graphics.rectangle('fill', w(.5) - (iw / 2), h(.35) + (ih / 2) + 1, iw, ih)
    
    love.graphics.setColor(112, 85, 67)
    love.graphics.print(self.username, w(.5) - (iw / 2) + (fh / 2), h(.35) - (fh / 2))
    if self.focused == 'username' then
      love.graphics.line(w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.username) + 1, h(.35) - (fh / 2), w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.username) + 1, h(.35) - (fh / 2) + fh)
    end
    love.graphics.print(string.rep('•', #self.password), w(.5) - (iw / 2) + (fh / 2), h(.35) - (fh / 2) + ih + 1)
    if self.focused == 'password' then
      love.graphics.line(w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(string.rep('•', #self.password)) + 1, h(.35) - (fh / 2) + ih + 1, w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(string.rep('•', #self.password)) + 1, h(.35) - (fh / 2) + ih + 1 + fh)
    end
  elseif self.page == 'main' then	
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(108, 89, 128)
    love.graphics.print('g', 20, 16)
    love.graphics.setColor(140, 107, 84)
    love.graphics.print('G', 20 + self.titleFont:getWidth('g'), 16)
    
    love.graphics.setFont(self.font)
    local fh = self.font:getHeight()
    local ih = math.max(40, fh)
    local iw = math.min(w(.3), 240)
    love.graphics.setColor(30, 30, 30)
    love.graphics.rectangle('fill', w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih)
    
    love.graphics.setColor(112, 85, 67)
    love.graphics.print(self.ip, w(.5) - (iw / 2) + (fh / 2), h(.35) - (fh / 2))
    if self.focused == 'ip' then
      love.graphics.line(w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.ip) + 1, h(.35) - (fh / 2), w(.5) - (iw / 2) + (fh / 2) + self.font:getWidth(self.ip) + 1, h(.35) - (fh / 2) + fh)
    end
	end
end

function Menu:update()
	--
end

function Menu.keypressed(key)
  local self = Menu
	if self.page == 'login' then
		if self.focused == 'username' then
			if #key == 1 and key:match('%w') then self.username = self.username .. key
			elseif key == 'backspace' then self.username = self.username:sub(1, -2)
			elseif key == 'tab' then self:focusInput('password') end
		elseif self.focused == 'password' then
			if #key == 1 and key:match('%w') then self.password = self.password .. key
			elseif key == 'backspace' then self.password = self.password:sub(1, -2)
			elseif key == 'tab' then self:focusInput('username')
			elseif key == 'return' then
				username = self.username
				password = self.password
				self.page = 'main'
			end
		end
	elseif self.page == 'main' then
		if key == 's' then love.filesystem.load('server/main.lua')() return
    elseif key == 'c' then 
      serverIp = self.ip
      serverPort = 6061
      
      Overwatch:unload()
      Overwatch = Game
      Overwatch:load()
      love.keyboard.setKeyRepeat(false)
    end
    
		if self.focused == 'ip' then
			if #key == 1 and key:match('[0-9%.]') then self.ip = self.ip .. key
			elseif key == 'backspace' then self.ip = self.ip:sub(1, -2)
			elseif key == 'return' then
				serverIp = self.ip
				serverPort = 6061
				
				Overwatch:unload()
				Overwatch = Game
				Overwatch:load()
        love.keyboard.setKeyRepeat(false)
			end
		end
	end
end

function Menu.mousepressed(x, y, button)
  local self = Menu
	self:unfocus()
	if self.page == 'login' then
		if button == 'l' then
			local fh = self.font:getHeight()
			local ih = math.max(40, fh)
			local iw = math.min(w(.3), 240)
			if math.inside(x, y, w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih) then self:focusInput('username')
			elseif math.inside(x, y, w(.5) - (iw / 2), h(.35) + (ih / 2) + 1, iw, ih) then self:focusInput('password') end
		end
	elseif self.page == 'main' then
		if button == 'l' then
			local fh = self.font:getHeight()
			local ih = math.max(40, fh)
			local iw = math.min(w(.3), 240)
			if math.inside(x, y, w(.5) - (iw / 2), h(.35) - (ih / 2), iw, ih) then self:focusInput('ip') end
		end
	end
end

function Menu:focusInput(key)
  self:unfocus()
  self.focused = key
  if self[self.focused .. 'Default'] and self[self.focused] == self[self.focused .. 'Default'] then self[self.focused] = '' end
end

function Menu:unfocus()
  if not self.focused then return end
  if self[self.focused] == '' and self[self.focused .. 'Default'] then self[self.focused] = self[self.focused .. 'Default'] end
  self.focused = nil
end
