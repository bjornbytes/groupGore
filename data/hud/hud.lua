Hud = class()

local g = love.graphics

function Hud:init()
  self.depth = -10000
  self._debug = false

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
  
  ctx.event:on(evtChat, function(data) self.chat:add(data) end)
  ctx.event:on(evtDead, function(data) self.feed:insert(data) end)
  ctx.view:register(self)
end

function Hud:update()
  if self.classSelect.active then return self.classSelect:update() end

  self.health:update()
  self.chat:update()
  self.feed:update()
  self.icons:update()
end

function Hud:gui()
  g.reset()
  
  if not ctx.id then return self:connecting() end
  if self.classSelect.active then return self.classSelect:draw() end

  self.players:draw()
  self.blood:draw()
  self.left:draw()
  self.health:draw()
  self.icons:draw()
  self.right:draw()
  self.buffs:draw()
  self.feed:draw()
  self.chat:draw()
  self:crosshair()
  if self._debug then self.debug:draw() end
end

function Hud:mousepressed(x, y, button)
  return self.classSelect:mousepressed(x, y, button)
end

function Hud:mousereleased(x, y, button)
  return self.classSelect:mousereleased(x, y, button)
end

function Hud:textinput(character)
  self.chat:textinput(character)
end

function Hud:keypressed(key)
  if self.chat:keypressed(key) then return true
  elseif self.classSelect:keypressed(key) then return true
  elseif key == '`' then self._debug = not self._debug end
end

function Hud:keyreleased(key)
  if self.chat.active or self.classSelect.active then return true end
end

function Hud:connecting()
  --[[g.setColor(0, 0, 0)
  g.rectangle('fill', 0, 0, g.getWidth(), g.getHeight())
  g.setColor(255, 255, 255)
  local str = 'Connecting...'
  if tick > 5 / tickRate then str = str .. '\noshit' end
  if tick > 6 / tickRate then str = str .. ' oshit' end
  if tick > (6 / tickRate) + 5 then str = str .. ' oshit' end
  if tick > (6 / tickRate) + 10 then str = str .. ' oshit' end
  if tick > 10 / tickRate then str = str .. '\n' str = str .. string.rep('fuck', math.min(10, (tick - (10 / tickRate)) / 3)) end
  g.printf(str, 0, math.floor(g.height() / 2 - g.height(.02)), g.getWidth(), 'center')]]
end

function Hud:crosshair()
  local p = ctx.players:get(ctx.id)
  if p then
    local weapon = p.slots[p.weapon]
    if weapon.crosshair then
      if love.mouse.isVisible() then love.mouse.setVisible(false) end
      weapon:crosshair()
    else
      if not love.mouse.isVisible() then love.mouse.setVisible(true) end
    end
  end
end