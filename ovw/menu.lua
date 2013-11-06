Menu = {}

function Menu:load()
  self.bg = love.graphics.newImage('media/graphics/menu/background.png')
  self.ip = '127.0.0.1'
end

function Menu:unload()
  self.bg = nil
end

function Menu:draw()
  love.graphics.draw(self.bg, 0, 0)
  love.graphics.printf('groupGore\n' .. self.ip, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
end

function Menu:update()
  if love.keyboard.isDown('s') then
    love.filesystem.load('server/main.lua')()
  elseif love.keyboard.isDown('c') then
    serverIp = self.ip
    serverPort = 6061
    username = 'tie372' .. math.floor(love.timer.getTime()) % 100
    
    Overwatch:unload()
    Overwatch = Game
    Overwatch:load()
  end
end

function Menu.keypressed(key)
  if key:match('[0-9\.]') then
    Menu.ip = Menu.ip .. key
  elseif key == 'backspace' then
    Menu.ip = Menu.ip:sub(1, -2)
  end
end
