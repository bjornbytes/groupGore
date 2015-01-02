Menu = class()

function Menu:load(user)
  self.user = user or {}

  love.audio.tags.all.stop()
  love.window.setMode(800, 600, {fullscreen = false})
  self:resize()
  love.mouse.setGrabbed(false)
  love.mouse.setCursor(love.mouse.newCursor('data/media/graphics/cursor.png'))
  love.mouse.setVisible(true)
  love.keyboard.setKeyRepeat(true)

  self.ribbon = MenuRibbon()
  self.background = MenuBackground()
  self.input = MenuInput()
  self.options = MenuOptions()
  self.back = MenuBack()
  self.alert = MenuAlert()

  self.pages = {
    login = MenuLogin(),
    main = MenuMain(),
    serverlist = MenuServerList()
  }
  
  self:push(self.user.token and 'main' or 'login')

  self.u, self.v = love.graphics.getDimensions()
end

function Menu:update()
  self.alert:update()
  self:run('update')
end

function Menu:draw()
  self.background:draw()
  self.ribbon:draw()
  self.back:draw()
  self:run('draw')
  self.alert:draw()
end

function Menu:keypressed(...)
  self.input:keypressed(...)
  return self:run('keypressed', ...)
end

function Menu:keyreleased(key)
  if key == 'escape' then love.event.quit() end
  return self:run('keyreleased', key)
end

function Menu:mousepressed(...)
  return self:run('mousepressed', ...)
end

function Menu:mousereleased(...)
  self.back:mousereleased(...)
  return self:run('mousereleased', ...)
end

function Menu:textinput(...)
  self.input:textinput(...)
  return self:run('textinput', ...)
end

function Menu:resize()
  self.u, self.v = love.graphics.getDimensions()
  self:run('resize')
  Typo.resize()
end

function Menu:run(key, ...)
  if not self.page or not self.pages[self.page] then return end
  local page = self.pages[self.page]
  f.exe(page[key], page, ...)
end

function Menu:push(page, ...)
  self:run('deactivate', page)
  self.page = page
  self:run('activate', ...)
end

function Menu:connect(ip)
  serverIp = ip
  serverPort = 6061
  Context:remove(self)
  Context:add(Game, self.options.data)
  love.keyboard.setKeyRepeat(false)
end
