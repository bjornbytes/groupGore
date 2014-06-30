require 'love.filesystem'
local timer = require 'love.timer'

local inbox = love.thread.getChannel('goregous.in')
local outbox = love.thread.getChannel('goregous.out')

local socket = (require('socket')).tcp()
socket:settimeout(10)

local _, e = socket:connect('107.4.63.70', 6060)
if e then error('Can\'t connect to goregous') end 

socket:settimeout(0)

while true do
  while inbox:getCount() > 0 do
    local data = inbox:pop()
    if data == 'quit' then
      socket:close()
      return
    end
    print('Sending ' .. data[1])
    socket:send(table.concat(data, ',') .. '\n')
  end

  while true do
    local str = socket:receive('*l')
    if not str then break end
    print('Received "' .. str .. '"')
    local data = {}
    for word in string.gmatch(str, '([^,]+)') do
      table.insert(data, word)
    end
    outbox:push(data)
  end

  love.timer.sleep(.1)
end
