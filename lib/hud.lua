Hud = class()

local function w(x) x = x or 1 return love.window.getWidth() * x end
local function h(x) x = x or 1 return (love.window.getHeight() - ovw.view.margin * 2) * x end
local g = love.graphics
local d = Draw

function Hud:init()
  self.health = {}
  self.health.canvas = love.graphics.newCanvas(160, 160)
  self.health.back = love.graphics.newImage('media/graphics/healthBack.png')
  self.health.glass = love.graphics.newImage('media/graphics/healthGlass.png')
  self.health.red = love.graphics.newImage('media/graphics/healthRed.png')
  
  self.font = love.graphics.newFont('media/fonts/aeroMatics.ttf', h() * .02)

  self.chatting = false
  self.chatMessage = ''
  self.chatLog = ''
  
  self.skillBg = love.graphics.newImage('media/graphics/skills.png')

  ovw.event:on(evtChat, self, function(self, data)
    self:updateChat(data.message)
  end)
end

function Hud:update()
  if myId and ovw.players:get(myId).active then
    self.health.canvas:clear()
    self.health.canvas:renderTo(function()
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(self.health.red, 4, 13)
      love.graphics.setBlendMode('subtractive')
      love.graphics.setColor(255, 255, 255, 255)
      local p = ovw.players:get(myId)
      love.graphics.arc('fill', 80, 80, 80, 0, 0 - ((2 * math.pi) * (1 - (p.health / p.maxHealth))))
      love.graphics.setBlendMode('alpha')
    end)
  end
end

function Hud:draw()
  g.reset()
  g.setFont(self.font)
  
  if not myId then
    g.setColor(0, 0, 0)
    g.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
    g.setColor(255, 255, 255)
    local str = 'Connecting...'
    if tick > 5 / tickRate then
      str = str .. '\noshit'
    end
    if tick > 6 / tickRate then
      str = str .. ' oshit'
    end
    if tick > (6 / tickRate) + 5 then
      str = str .. ' oshit'
    end
    if tick > (6 / tickRate) + 10 then
      str = str .. ' oshit'
    end
    if tick > 10 / tickRate then
      str = str .. '\n'
      str = str .. string.rep('fuck', math.min(10, (tick - (10 / tickRate)) / 3))
    end
    g.printf(str, 0, math.floor(love.window.getHeight() / 2 - self.font:getHeight()), love.window.getWidth(), 'center')
    return
  end
  
  if self:classSelect() then
    g.setFont(self.font)
    g.setColor(0, 0, 0, 140)
    d.rectCentered('fill', w(.5), h(.5), w(.9), h(.82))
    g.setColor(255, 255, 255, 40)
    d.rectCentered('line', w(.5), h(.5), w(.9), h(.82))
    
    g.setColor(255, 255, 255, 180)
    d.printCentered('Choose Class:', w(.5), h(.12))
    local x = w(.5) - (w(.9) / 2) + w(.05)
    local y = h(.5) - (h(.82) / 2) + w(.05)
    for i = 1, #data.class do
      g.rectangle('line', x, y, w(.06), w(.06))
      x = x + w(.08)
      if i % 4 == 0 then x = w(.5) - (w(.9) / 2) + w(.05) y = y + w(.08) end
    end
    return
  end
  
  local s = math.min(1, h(.2) / 160)
  g.draw(self.health.back, 12 * s, 12 * s, 0, s, s)
  g.draw(self.health.canvas, 4 * s, 4 * s, 0, s, s)
  g.draw(self.health.glass, 0, 0, 0, s, s)

  love.graphics.setFont(self.font)
  ovw.players:with(ovw.players.active, function(p)
    if p.team == purple then love.graphics.setColor(190, 160, 220, p.visible * 255)
    elseif p.team == orange then love.graphics.setColor(240, 160, 140, p.visible * 255) end
    d.printCentered(p.username, (p.x - ovw.view.x) * ovw.view.scale, ((p.y - ovw.view.y) * ovw.view.scale) - 60)

    if not p.ded then
      g.setColor(0, 0, 0, 128 * p.visible)
      g.rectangle('fill', ((p.x - ovw.view.x) * ovw.view.scale) - 40, ((p.y - ovw.view.y) * ovw.view.scale) - 50, 80, 10)
      g.setColor(100, 0, 0, 128 * p.visible)
      g.rectangle('fill', ((p.x - ovw.view.x) * ovw.view.scale) - 40, ((p.y - ovw.view.y) * ovw.view.scale) - 50, (p.health / p.maxHealth) * 80, 10)
      g.setColor(100, 0, 0, 255 * p.visible)
      d.rectCentered('line', (p.x - ovw.view.x) * ovw.view.scale, ((p.y - ovw.view.y) * ovw.view.scale) - 45, 80, 10)
    end
  end)
  
  local p = ovw.players:get(myId)
  if p and p.active then
    g.draw(self.skillBg, w(.5), h(.01), 0, w(.35) / self.skillBg:getWidth(), w(.35) / self.skillBg:getWidth(), self.skillBg:getWidth() / 2, 0)
    for i = 1, 5 do
      g.setColor(100, 100, 100)
      if p.input.weapon == i or p.input.skill == i then g.setColor(180, 180, 180) end
      if p.slots[i].type == 'passive' then g.setColor(100, 50, 50) end
      d.rectCentered('line', w(.5) - w(.1250) + (w(.0620) * (i - 1)), h(.08), w(.042), w(.042), true)
    end
  end

  if ovw.map.hud then ovw.map:hud() end
  
  self:drawChat()
  self:drawDebug()
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
    if key == 'return' then
      self.chatting = true
      self.chatMessage = ''
      love.keyboard.setKeyRepeat(true)
    end
  end
end

function Hud:keyreleased(key)
  if self.chatting then return true end
end

function Hud:drawChat()
  local height = h(.25) + 2
  if self.chatting then height = height + (self.font:getHeight() + 6.5) end
  g.setColor(0, 0, 0, 180)
  g.rectangle('fill', 4, h() - (height + 4), w(.25), height)
  g.setColor(30, 30, 30, 180)
  g.rectangle('line', 4, h() - (height + 4), w(.25), height)
  g.setFont(self.font)
  local yy = h() - 4
  if self.chatting then
    g.setColor(255, 255, 255, 60)
    g.line(4.5, h() - 4 - self.font:getHeight() - 6.5, 3 + w(.25), h() - 4 - self.font:getHeight() - 6.5)
    g.setColor(255, 255, 255, 180)
    g.print(self.chatMessage .. (self.chatting and '|' or ''), 4 + 4, math.round(yy - self.font:getHeight() - 5.5 + 2))
    yy = yy - self.font:getHeight() - 6.5
  end

  if self.chatText then
    self.chatText:draw(4 + 4, math.round(yy - (self.font:getHeight() * select(2, self.font:getWrap(self.chatLog, w(.25)))) - 4))
  end
end

function Hud:drawDebug()
  g.setColor(255, 255, 255)
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
  self.chatText = rich.new({self.chatLog, nil, white = {255, 255, 255}, purple = {190, 160, 220}, orange = {240, 160, 140}})
end

function Hud:classSelect() return myId and not ovw.players:get(myId).active end
