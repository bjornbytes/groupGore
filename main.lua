require 'enet'
require './lib/util'
require './lib/class'
require './lib/linkedlist'
require './lib/stream'

require './ovw/ovw'
require './ovw/menu'
require './ovw/game'

require './event'
require './map'
require './collision'
require './buff'
require './view'
require './particle'
require './hud'

require './net'
require './tag/netclient'
require './tag/netserver'

require './player'
require './players'

require './spell'
require './spells'

require './server/server'

require './data/loader'

function love.load()
  data.load()

  Overwatch:add(Menu)

  love.update = Overwatch.update
  love.draw = Overwatch.draw
  love.sync = Overwatch.sync
  love.quit = Overwatch.quit
  
  love.handlers = {}
  setmetatable(love.handlers, {__index = Overwatch})
end

function love.run()
  math.randomseed(os.time()) math.random()

  tick = 0
  tickRate = .02
  tickDelta = 0
  syncRate = .05
  syncDelta = 0
  interp = .1

  love.load(arg)

  local delta = 0

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
    
    love.timer.sleep(.001)
  end
end
