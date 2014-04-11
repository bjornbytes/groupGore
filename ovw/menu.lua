Menu = class()

function Menu:load()
  self.background = MenuBackground()
  self.ribbon = MenuRibbon()
  self.input = MenuInput()
  self.login = MenuLogin()
  self.main = MenuMain()
  
  if not username then
    self:changePage(self.login)
  else
    self:changePage(self.main)
  end
  
  self.container = Container()
end

function Menu:draw()
  self.background:draw()
  self.ribbon:draw()
  f.exe(self.page.draw, self.page)
end

function Menu:keypressed(key)
  if key == 'escape' then love.event.quit() end
  self.input:keypressed(key)
end

function Menu:textinput(char)
  self.input:textinput(char)
end

function Menu:mousepressed(x, y, button)
  f.exe(self.page.mousepressed, self.page, x, y, button)
end

function Menu:resize()
  Typo:resize()
end

function Menu:changePage(page)
  if not page then return end
  if self.page and self.page.unload then self.page:unload() end
  self.page = page
  self.page:load()
end
