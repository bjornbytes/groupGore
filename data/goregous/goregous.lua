local timer = require 'love.timer'
local json = require 'lib/deps/dkjson'

local inbox = love.thread.getChannel('goregous.in')
local outbox = love.thread.getChannel('goregous.out')

local socket = (require('socket')).tcp()
socket:settimeout(10)

local _, e = socket:connect('127.0.0.1', 6060)
-- if e then error('Can\'t connect to goregous') end 

while true do
  while inbox:getCount() > 0 do
    local message = inbox:pop()
    socket:send(json.encode({color = 'purple'}))
  end

  love.timer.sleep(.1)
end
