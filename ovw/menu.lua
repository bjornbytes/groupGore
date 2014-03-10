function w(x) x = x or 1 return love.window.getWidth() * x end
function h(x) x = x or 1 return love.window.getHeight() * x end

Menu = extend(Overwatch)

function Menu:init()    
  love.keyboard.setKeyRepeat(true)
  
  self:addComponent(MenuBackground)
  self:addComponent(MenuRibbon)
  self:addComponent(MenuLogin)

  self:bindComponents()
end