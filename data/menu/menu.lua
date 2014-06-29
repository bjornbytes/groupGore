Menu = class()

function Menu:load()
  love.audio.tags.all.stop()

  love.window.setMode(800, 600, {fullscreen = false, resizable = false})
  love.mouse.setGrabbed(false)
  love.mouse.setCursor(love.mouse.newCursor('data/media/graphics/cursor.png'))
  love.mouse.setVisible(true)

  self.background = MenuBackground()
  self.ribbon = MenuRibbon()
  self.input = MenuInput()
  self.loader = MenuLoader()
  self.error = MenuError()
  self.back = MenuBack()
  self.login = MenuLogin()
  self.main = MenuMain()
  self.serverlist = MenuServerList()

  self.pages = {}
  
  if not username then
    self:push(self.login)
  else
    self:push(self.main)
  end
  
  self.container = Container()

  local goregous = love.thread.newThread('data/goregous/goregous.lua')
  goregous:start()
end

function Menu:update()
  local outbox = love.thread.getChannel('goregous.out')
  while outbox:getCount() > 0 do
    local data = outbox:pop()
    if data[1] == 'login' then
      self.loader:deactivate()
      if data[2] == 'ok' then
        self:push(self.main)
      elseif data[2] == 'duplicate' then
        self.error:activate('Nickname already in use')
      else
        self.error:activate('Problem logging in')
      end
    elseif data[1] == 'createServer' then
      self.loader:deactivate()
      if data[2] == 'ok' then
        Context:add(Server)
        self.main:connect('localhost')
      elseif data[2] == 'duplicate' then
        self.error:activate('You are already running a server')
      else
        self.error:activate('Unable to create server')
      end
    elseif data[1] == 'listServers' then
      table.remove(data, 1)
      self.serverlist:setServers(data)
      self.loader:deactivate()
    end
  end

  self.loader:update()
  self.error:update()
end

function Menu:draw()
  self.background:draw()
  self.ribbon:draw()
  self.back:draw()
  local page = self.pages[#self.pages]
  f.exe(page.draw, page)
  self.loader:draw()
  self.error:draw()
end

function Menu:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'backspace' then self:pop() end
  self.input:keypressed(key)
  local page = self.pages[#self.pages]
  f.exe(page.keypressed, page, key)
end

function Menu:textinput(char)
  self.input:textinput(char)
end

function Menu:mousepressed(x, y, button)
  local page = self.pages[#self.pages]
  f.exe(page.mousepressed, page, x, y, button)
  self.back:mousepressed(x, y, button)
end

function Menu:resize()
  Typo:resize()
end

function Menu:push(page)
  if not page then return end
  local old = self.pages[#self.pages]
  if old and old.unload then old:unload() end
  table.insert(self.pages, page)
  if page.load then page:load() end
end

function Menu:pop()
  if #self.pages == 1 then return end
  local old = self.pages[#self.pages]
  if old and old.unload then old:unload() end
  table.remove(self.pages)
  local new = self.pages[#self.pages]
  if new and new.load then new:load() end
end

function Menu:threaderror(thread, e)
  error(e)
end
