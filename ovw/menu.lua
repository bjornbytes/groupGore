Menu = class()

function w(x) x = x or 1 return love.window.getWidth() * x end
function h(x) x = x or 1 return love.window.getHeight() * x end

function Menu:load()
  self.background = MenuBackground()
  self.ribbon = MenuRibbon()
  self.input = MenuInput()
  self.login = MenuLogin()
  self.main = MenuMain()
  
  self:changePage(self.login)
end

function Menu:draw()
  self.background:draw()
  self.ribbon:draw()
  f.exe(self.page.draw, self.page)
end

function Menu:keypressed(key)
  self.input:keypressed(key)
end

function Menu:textinput(char)
  self.input:textinput(char)
end

function Menu:mousepressed(x, y, button)
  f.exe(self.page.mousepressed, self.page, x, y, button)
end

function Menu:changePage(page)
  if self.page and self.page.unload then self.page:unload() end
  self.page = page
  self.page:load()
end