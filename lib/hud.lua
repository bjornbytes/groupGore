Hud = class()

local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return (love.window.getHeight() - ovw.view.margin * 2) * x end
local g = love.graphics

function Hud:init()
  self.health = {}
  self.health.canvas = g.newCanvas(160, 160)
  self.health.back = g.newImage('media/graphics/healthBack.png')
  self.health.glass = g.newImage('media/graphics/healthGlass.png')
  self.health.red = g.newImage('media/graphics/healthRed.png')
  self.health.val = 0
  self.health.prevVal = 0
  
  self.font = g.newFont('media/fonts/aeromatics.ttf', h() * .02)

  self.chatting = false
  self.chatMessage = ''
  self.chatLog = ''
  self.chatTimer = 0
  self.chatOffset = -w(.25) - 4

  self.killfeed = {}
  self.killfeedAlpha = 0

  self.slotSmallFont = g.newFont('media/fonts/aeromatics.ttf', h() * .018)
  self.slotFont = g.newFont('media/fonts/aeromatics.ttf', h() * .025)
  self.slotFrameLeft = {}
  self.slotFrameRight = {}
  self.slotWidth = {}
  self.targetSlotWidth = {}
  for i = 1, 5 do
    self.slotFrameLeft[i] = g.newCanvas(w(.02), w(.04))
    self.slotFrameRight[i] = g.newCanvas(w(.02), w(.04))
    self.slotFrameLeft[i]:renderTo(function()
      g.setColor(0, 0, 0)
      g.arc('fill', w(.02), w(.02), w(.02), math.pi * .5, math.pi * 1.5)
      g.setBlendMode('subtractive')
      g.arc('fill', w(.02), w(.02), w(.012), math.pi * .5, math.pi * 1.5)
      g.setBlendMode('alpha')
    end)

    self.slotFrameRight[i]:renderTo(function()
      g.setColor(90, 0, 0)
      g.arc('fill', 0, w(.02), w(.02), -math.pi * .5, math.pi * .5)
      g.setBlendMode('subtractive')
      g.arc('fill', 0, w(.02), w(.012), -math.pi * .5, math.pi * .5)
      g.setBlendMode('alpha')
    end)

    self.slotWidth[i] = 0
    self.targetSlotWidth[i] = 0
  end

  ovw.event:on(evtChat, self, function(self, data)
    self:updateChat(data.message)
  end)

  ovw.event:on(evtDead, self, function(self, data)
    while #self.killfeed > 3 do table.remove(self.killfeed, 1) end
    if #self.killfeed == 3 then self.killfeed[1].targetX = w() end
    for i = 1, #self.killfeed do self.killfeed[i].targetY = self.killfeed[i].targetY + h(.05) + 4 end
    local t = table.copy(data)
    t.x = w()
    t.y = -h(.05)
    t.targetX = w() - w(.14) - 4
    t.targetY = 4
    table.insert(self.killfeed, t)
    self.killfeedAlpha = 4
  end)
end

function Hud:update()
  local p = ovw.players:get(myId)
  if p and p.active then
    self.health.prevVal = self.health.val
    self.health.val = math.lerp(self.health.val, p.health, .25)
    self.health.canvas:clear()
    self.health.canvas:renderTo(function()
      g.setColor(255, 255, 255, 255)
      g.draw(self.health.red, 4, 13)
      g.setBlendMode('subtractive')
      g.setColor(255, 255, 255, 255)
      g.arc('fill', 80, 80, 80, 0, -((2 * math.pi) * (1 - (math.lerp(self.health.prevVal, self.health.val, tickDelta / tickRate) / p.maxHealth))))
      g.setBlendMode('alpha')
    end)

    for i = 1, 5 do
      self.slotFrameRight[i]:clear()
      self.slotFrameRight[i]:renderTo(function()
        g.setColor(90, 0, 0)
        local val = p.slots[i].value and p.slots[i].value(p.slots[i]) or 1
        g.arc('fill', 0, w(.02), w(.02), math.pi * .5, (math.pi * .5) - (val * math.pi))
        g.setBlendMode('subtractive')
        g.arc('fill', 0, w(.02), w(.012), math.pi * .5, (math.pi * .5) - (val * math.pi))
        g.setBlendMode('alpha')
      end)
    end
  end

  self.chatTimer = timer.rot(self.chatTimer)
  if self.chatting then self.chatTimer = 2 end
  self.chatOffset = math.lerp(self.chatOffset, (self.chatTimer == 0) and -w(.25) - 4 or 0, .25)

  for i = 1, #self.killfeed do
    local k = self.killfeed[i]
    k.x = math.lerp(k.x, k.targetX, .25)
    k.y = math.lerp(k.y, k.targetY, .25)
  end

  self.killfeedAlpha = timer.rot(self.killfeedAlpha)
  for i = 1, 5 do
    self.slotWidth[i] = math.lerp(self.slotWidth[i], self.targetSlotWidth[i], .25)
    if p and p.active and (p.input.weapon == i or p.input.skill == i) then self.targetSlotWidth[i] = w(.1)
    else self.targetSlotWidth[i] = 0 end
  end
end

function Hud:draw()
  g.reset()
  g.setFont(self.font)
  
  if not myId then return self:connecting() end
  if self:classSelect() then return self:drawClassSelect() end

  self:drawPlayerDetails()
  self:drawHealthbar()
  self:drawSlots()
  self:drawBuffs()
  self:drawKillfeed()
  self:drawChat()
  self:drawDebug()
  f.exe(ovw.map.hud, ovw.map)
end

function Hud:mousereleased(x, y, button)
  if self:classSelect() and button == 'l' then
    local rx = w(.5) - (w(.9) / 2) + w(.05)
    local ry = h(.5) - (h(.82) / 2) + w(.05) + ovw.view.margin
    for i = 1, #data.class do
      if math.inside(x, y, rx, ry, w(.06), w(.06)) then
        ovw.net:send(msgClass, {
          class = i,
          team = myId > 1 and 1 or 0
        })
      end
      rx = rx + w(.08)
      if i % 4 == 0 then rx = w(.5) - (w(.9) / 2) + w(.05) ry = ry + w(.08) end
    end
  end
end

function Hud:textinput(character)
  if self.chatting then self.chatMessage = self.chatMessage .. character end
end

function Hud:keypressed(key)
  if tick < 10 then return end

  if self.chatting then
    if key == 'backspace' then self.chatMessage = self.chatMessage:sub(1, -2)
    elseif key == 'return' then
      if #self.chatMessage > 0 then
        ovw.net:send(msgChat, {
          message = self.chatMessage
        })
      end
      self.chatting = false
      self.chatMessage = ''
      love.keyboard.setKeyRepeat(false)
    end
    return true
  else
    if self:classSelect() then
      for i = 1, #data.class do
        if key == tostring(i) then
          ovw.net:send(msgClass, {
            class = i,
            team = myId > 1 and 1 or 0
          })
        end
      end
    elseif key == 'return' then
      self.chatting = true
      self.chatMessage = ''
      love.keyboard.setKeyRepeat(true)
    elseif key == '`' then
      ovw.editor.active = not ovw.editor.active
    end
  end
end

function Hud:keyreleased(key)
  if self.chatting then return true end
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
  g.printf(str, 0, math.floor(love.window.getHeight() / 2 - self.font:getHeight()), love.window.getWidth(), 'center')
end

function Hud:drawClassSelect()
  g.setFont(self.font)
  g.setColor(0, 0, 0, 140)
  Gooey.rectangleCenter('fill', w(.5), h(.5), w(.9), h(.82))
  g.setColor(255, 255, 255, 40)
  Gooey.rectangleCenter('line', w(.5), h(.5), w(.9), h(.82))
  
  g.setColor(255, 255, 255, 180)
  Gooey.printCenter('Choose Class:', w(.5), h(.12))
  local x = w(.5) - (w(.9) / 2) + w(.05)
  local y = h(.5) - (h(.82) / 2) + w(.05)
  for i = 1, #data.class do
    g.rectangle('line', x, y, w(.06), w(.06))
    x = x + w(.08)
    if i % 4 == 0 then x = w(.5) - (w(.9) / 2) + w(.05) y = y + w(.08) end
  end
end

function Hud:drawPlayerDetails()
  g.setFont(self.font)
  ovw.players:with(ovw.players.active, function(p)
    if p.team == purple then g.setColor(190, 160, 220, p.visible * 255)
    elseif p.team == orange then g.setColor(240, 160, 140, p.visible * 255) end
    Gooey.printCenter(p.username, (p.x - ovw.view.x) * ovw.view.scale, ((p.y - ovw.view.y) * ovw.view.scale) - 60)

    if not p.ded then
      local x0 = ((p.x - ovw.view.x) * ovw.view.scale) - 40
      local y0 = ((p.y - ovw.view.y) * ovw.view.scale) - 50
      local healthWidth, shieldWidth = (p.health / p.maxHealth) * 80, (p.shield / p.maxHealth) * 80
      local totalWidth = math.max(healthWidth + shieldWidth, 80)

      g.setColor(0, 0, 0, 128 * p.visible) -- Dark background
      g.rectangle('fill', x0, y0, totalWidth, 10)
      
      g.setColor(200, 0, 0, 128 * p.visible) -- Health
      g.rectangle('fill', x0 + .5, y0 + .5, healthWidth - 1, 10 - 1)
      
      g.setColor(220, 220, 220, 128 * p.visible) -- Shield
      g.rectangle('fill', x0 + healthWidth, y0, shieldWidth, 10)
      
      g.setColor(150, 0, 0, 255 * p.visible) -- Frame
      g.rectangle('line', x0, y0, totalWidth, 10)
    end
  end)
end

function Hud:drawHealthbar()
  local p = ovw.players:get(myId)
  if p and p.active then
    local s = math.min(1, h(.2) / 160)
    g.setColor(255, 255, 255)
    g.draw(self.health.back, 12 * s, 12 * s, 0, s, s)
    g.draw(self.health.canvas, 4 * s, 4 * s, 0, s, s)
    g.draw(self.health.glass, 0, 0, 0, s, s)
    Gooey.printCenter(math.ceil(p.health), (4 * s) + (s * self.health.canvas:getWidth() / 2) - 3, (4 * s) + (s * self.health.canvas:getHeight() / 2))
  end
end

function Hud:drawSlots()
  local p = ovw.players:get(myId)
  if p and p.active then
    for i = 1, 5 do
      local y = h(.3) + ((i - 1) * w(.045))
      g.setColor(0, 0, 0, 200)
      g.rectangle('fill', w(.03), y - w(.02) + w(.004), self.slotWidth[i], w(.04) - w(.008))
      g.arc('fill', w(.03) + self.slotWidth[i], y - w(.02) + w(.004) + w(.016), w(.0175), math.pi * -.5, math.pi * .5)
      g.setColor(255, 255, 255)
      if self.slotWidth[i] > 0 then
        g.setFont(self.slotFont)
        g.print(p.slots[i].name, w(.03) + (w(.025) * (self.slotWidth[i] / w(.1))), y - (g.getFont():getHeight() / 2), 0, self.slotWidth[i] / w(.1), 1)
      end
      g.setColor(120, 0, 0, 255)
      g.circle('fill', w(.03), y, w(.0175))
      g.setColor(140, 140, 140)
      g.line(w(.03), y - w(.02) + w(.004), w(.03) + self.slotWidth[i], y - w(.02) + w(.004))
      g.line(w(.03), y + w(.02) - w(.004), w(.03) + self.slotWidth[i], y + w(.02) - w(.004))
      g.setColor(255, 255, 255)
      g.draw(self.slotFrameLeft[i], w(.03) - w(.02), y - w(.02))
      g.draw(self.slotFrameRight[i], w(.03) + self.slotWidth[i], y - w(.02))
      g.setColor(255, 255, 255)
      g.setFont(self.slotSmallFont)
      Gooey.printCenter(i, w(.03) - w(.02) + w(.004), y)
    end
    g.setFont(self.font)
  end
end

function Hud:drawBuffs()
  local p = ovw.players:get(myId)
  if p and p.active then
    g.setColor(255, 255, 255)
    local xx = h(.2) + h(.02)
    table.each(ovw.buffs.buffs, function(b)
      if b.target == p.id then
        g.rectangle('line', xx, h(.02), w(.02), w(.02))
        xx = xx + w(.025)
      end
    end)
  end
end

function Hud:drawKillfeed()
  local alpha = math.min(self.killfeedAlpha, 1)
  for i = 1, #self.killfeed do
    local k = self.killfeed[i]
    g.setColor(0, 0, 0, 200 * alpha)
    g.rectangle('fill', k.x, k.y, w(.14), h(.05))

    local yy = h(.025) - (g.getFont():getHeight() / 2)
    local killer = ovw.players:get(k.kill)
    if killer.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(killer.username, k.x + 8, k.y + yy)

    local victim = ovw.players:get(k.id)
    if victim.team == purple then g.setColor(190, 160, 220, 255 * alpha)
    else g.setColor(240, 160, 140, 255 * alpha) end
    g.print(victim.username, k.x + w(.14) - g.getFont():getWidth(victim.username) - 9, k.y + yy)
  end
end

function Hud:drawChat()
  local height = h(.25) + 2
  if self.chatting then height = height + (self.font:getHeight() + 6.5) end
  g.setColor(0, 0, 0, 180)
  g.rectangle('fill', 4 + self.chatOffset, h() - (height + 4), w(.25), height)
  g.setColor(30, 30, 30, 180)
  g.rectangle('line', 4 + self.chatOffset, h() - (height + 4), w(.25), height)
  g.setFont(self.font)
  local yy = h() - 4
  if self.chatting then
    g.setColor(255, 255, 255, 60)
    g.line(4.5 + self.chatOffset, h() - 4 - self.font:getHeight() - 6.5, 3 + w(.25) + self.chatOffset, h() - 4 - self.font:getHeight() - 6.5)
    g.setColor(255, 255, 255, 180)
    g.printf(self.chatMessage .. (self.chatting and '|' or ''), 4 + 4 + self.chatOffset, math.round(yy - self.font:getHeight() - 5.5 + 2), w(.25), 'left')
    yy = yy - self.font:getHeight() - 6.5
  end

  if self.chatText then
    self.chatText:draw(4 + 4 + self.chatOffset, math.round(yy - (self.font:getHeight() * select(2, self.font:getWrap(self.chatLog, w(.25) - 2))) - 4))
  end
end

function Hud:drawDebug()
  g.setColor(255, 255, 255, 100)
  local debug = love.timer.getFPS() .. 'fps'
  if ovw.net.server then
    debug = debug .. ', ' .. ovw.net.server:round_trip_time() .. 'ms'
    debug = debug .. ', ' .. math.floor(ovw.net.host:total_sent_data() / 1000 + .5) .. 'tx'
    debug = debug .. ', ' .. math.floor(ovw.net.host:total_received_data() / 1000 + .5) .. 'rx'
  end
  g.print(debug, w() - self.font:getWidth(debug), h() - self.font:getHeight())
end

function Hud:updateChat(message)
  if #message > 0 then
    if #self.chatLog > 0 then self.chatLog = self.chatLog .. '\n' end
    self.chatLog = self.chatLog .. message
  end

  while self.font:getHeight() * select(2, self.font:getWrap(self.chatLog, w(.25))) > (h(.25) - 2) do
    self.chatLog = self.chatLog:sub(2)
  end
  self.chatText = rich.new({self.chatLog, w(.25) - 2, white = {255, 255, 255}, purple = {190, 160, 220}, orange = {240, 160, 140}})
  self.chatTimer = 2
end

function Hud:classSelect() return myId and not ovw.players:get(myId).active end
