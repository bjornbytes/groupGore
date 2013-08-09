Menu = {}

function Menu:load()
  print('Loading menu')
  self.bg = love.graphics.newImage('media/graphics/menu/background.png')
end

function Menu:unload()
  self.bg = nil
end

function Menu:draw()
  love.graphics.draw(self.bg, 0, 0)
  love.graphics.printf('groupGore', 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
  love.timer.sleep(.1)
end

function Menu:update()
  if love.keyboard.isDown('s') then
    love.filesystem.load('server/main.lua')()
  elseif love.keyboard.isDown('c') then
    serverIp = '127.0.0.1'
    serverPort = 6061
    username = 'tie372' .. math.floor(love.timer.getMicroTime()) % 100
    
    Overwatch:unload()
    Overwatch = Game
    Overwatch:load()
  end
end