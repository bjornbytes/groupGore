Menu = class()

function Menu:load()
  self.background = MenuBackground()
  self.ribbon = MenuRibbon()
  self.input = MenuInput()
  self.back = MenuBack()
  self.login = MenuLogin()
  self.main = MenuMain()

  self.pages = {}
  
  if not username then
    self:push(self.login)
  else
    self:push(self.main)
  end
  
  self.container = Container()
end

function Menu:draw()
  self.background:draw()
  self.ribbon:draw()
  self.back:draw()
  local page = self.pages[#self.pages]
  f.exe(page.draw, page)
end

function Menu:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'backspace' then self:pop() end
  self.input:keypressed(key)
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