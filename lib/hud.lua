Hud = class()

local g = love.graphics

function Hud:init()
  self.players = HudPlayers()
  self.blood = HudBlood()
  self.left = HudLeft()
  self.health = HudHealth()
  self.icons = HudIcons()
  self.right = HudRight()
  self.buffs = HudBuffs()
  self.feed = HudFeed()
  self.chat = HudChat()
  self.classSelect = HudClassSelect()
  self.debug = HudDebug()
  
  ovw.event:on(evtChat, function(data) self.chat:add(data) end)
  ovw.event:on(evtDead, function(data) self.feed:insert(data) end)
  ovw.view:register(self)
end

function Hud:update()
  self.health:update()
  self.chat:update()
  self.feed:update()
  self.classSelect:update()
  self.icons:update()
end

function Hud:gui()
  g.reset()
  
  if not myId then return self:connecting() end
  if self.classSelect:active() then return self.classSelect:draw() end

  self.players:draw()
  self.blood:draw()
  self.left:draw()
  self.health:draw()
  self.icons:draw()
  self.right:draw()
  self.buffs:draw()
  self.feed:draw()
  self.chat:draw()
  self.debug:draw()
end

function Hud:mousereleased(x, y, button)
  self.classSelect:mousereleased(x, y, button)
end

function Hud:textinput(character)
  self.chat:textinput(character)
end

function Hud:keypressed(key)
  if tick < 10 then return end

  if self.chat:keypressed(key) then return true
  elseif self.classSelect:keypressed(key) then return true
  elseif self.icons:keypressed(key) then return end
end

function Hud:keyreleased(key)
  if self.chat.active then return true end
end

function Hud:connecting()
  g.setColor(0, 0, 0)
  g.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
  g.setColor(255, 255, 255)
  local str = 'Connecting...'
  if tick > 5 / tickRate then str = str .. '\noshit' end
  if tick > 6 / tickRate then str = str .. ' oshit' end
  if tick > (6 / tickRate) + 5 then str = str .. ' oshit' end
  if tick > (6 / tickRate) + 10 then str = str .. ' oshit' end
  if tick > 10 / tickRate then str = str .. '\n' str = str .. string.rep('fuck', math.min(10, (tick - (10 / tickRate)) / 3)) end
  g.printf(str, 0, math.floor(love.window.getHeight() / 2 - love.graphics.height(.02)), love.window.getWidth(), 'center')
end
