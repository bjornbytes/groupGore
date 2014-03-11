function love.run()
  math.randomseed(os.time()) math.random()

  tick = 0
  tickRate = .02
  tickDelta = 0
  syncRate = .05
  syncDelta = 0
  interp = .1

  love.load(arg)

  delta = 0

  while true do
    love.timer.step()
    delta = love.timer.getDelta()

    tickDelta = tickDelta + delta
    while tickDelta >= tickRate do
      tick = tick + 1
      tickDelta = tickDelta - tickRate
      
      love.event.pump()
      local releases = {}
      for e, a, b, c, d in love.event.poll() do
        if e == 'quit' then f.exe(love.quit) love.audio.stop() return
        elseif e == 'mousereleased' or e == 'keyreleased' then table.insert(releases, {e, a, b, c, d})
        else love.handlers[e](a, b, c, d) end
      end
      
      love.update()
      
      for _, e in pairs(releases) do
        love.handlers[e[1]](e[2], e[3], e[4], e[5])
      end
    end

    syncDelta = syncDelta + delta
    if syncDelta >= syncRate then
      love.sync()
      syncDelta = 0
    end
    
    love.graphics.clear()
    love.draw()
    love.graphics.present()
    
    love.timer.sleep(.006)
  end
end

function love.graphics.rectangleCenter(style, x, y, w, h, pix)
  local ox, oy = math.round(x - (w / 2)), math.round(y - (h / 2))
  if pix then ox = ox + .5 oy = oy + .5 end
  love.graphics.rectangle(style, ox, oy, w, h)
end

function love.graphics.printCenter(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (love.graphics.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (love.graphics.getFont():getHeight() / 2) or 0)
  love.graphics.print(str, xx, yy)
end