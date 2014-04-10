local lust = {}
lust.level = 0

-- Setup
if love.math then
  love.math.setRandomSeed(os.time())
end

tick = 0
tickRate = .02
tickDelta = 0
syncRate = .05
syncDelta = 0
interp = .1
delta = 0

local update = love.update
love.update = function()
  tick = tick + 1
  love.event.pump()
  for e, a, b, c, d in love.event.poll() do
    if e == 'quit' then f.exe(love.quit) love.audio.stop() return
    else love.handlers[e](a, b, c, d) end
  end
  update()
  love.sync()
end
love.load = function() end
--

lust.wait = function(n)
  local i = 0
  repeat
    update()
    i = i + 1
  until i == n
end

lust.waitUntil = function(f, n)
  local i = 0
  while not f() do
    update()
    i = i + 1
    if i == n then error('timeout!') end
  end
end

function lust.describe(name, fn)
  print(string.rep('\t', lust.level) .. name)
  lust.level = lust.level + 1
  fn()
  lust.level = lust.level - 1
  if lust.level == 0 then
    love.graphics.setBackgroundColor(35, 35, 35)
    love.graphics.clear()
    love.graphics.setFontPixel('pixel', 8)
    local font = love.graphics:getFont()
    love.graphics.setColor(0, 192, 0)
    love.graphics.printf('all clear', 64, 64 + font:getHeight() * 4, love.graphics.getWidth() - 64)
    love.graphics.present()
    
    love.timer.sleep(.6)
    love.event.quit()
  end
end

function lust.it(name, fn)
  print(string.rep('\t', lust.level) .. name)
  lust.level = lust.level + 1
  local success, err = pcall(fn)
  if not success then
    print(string.rep('\t', lust.level) .. 'FAIL: ' .. err)
    error(name .. ' (' .. err .. ')', 0)
  else
    print(string.rep('\t', lust.level) .. 'PASS')
  end
  lust.level = lust.level - 1
end

function lust.with(o, fn)
  ovw = o
  fn()
  ovw = nil
end

-- Assertions
local function isa(v, x)
  if type(x) == 'string' then return type(v) == x, tostring(v) .. ' is not a ' .. x end
  return getmetatable(v).__index == x, 'table is not a ' .. tostring(x)
end

local paths = {
  [''] = {'to'},
  to = {'have', 'equal', 'be', 'exist'},
  be = {'a', 'an', 'truthy', 'falsy', f = function(v, x)
    return table.eq(v, x), tostring(v) .. ' and ' .. tostring(x) .. ' are not strictly equal!'
  end},
  a = {f = isa},
  an = {f = isa},
  exist = {f = function(v) return v == nil, tostring(v) .. ' is nil!' end},
  truthy = {f = function(v) return v, tostring(v) .. ' is not truthy!' end},
  falsy = {f = function(v) return not v, tostring(v) .. ' is not falsy!' end},
  equal = {f = function(v, x) return v == x, tostring(v) .. ' and ' .. tostring(x) .. ' are not equal!' end},
  have = {f = function(v, x) return v[x], 'table does not have key ' .. tostring(x)  end}
}

function lust.expect(v)
  local assertion = {}
  assertion.val = v
  assertion.action = ''
  
  setmetatable(assertion, {
    __index = function(t, k)
      if table.has(paths[rawget(t, 'action')], k) then
        rawset(t, 'action', k)
        return t
      end
      return rawget(t, k)
    end,
    __call = function(t, ...)
      if paths[t.action].f then
        local res, err = paths[t.action].f(t.val, ...)
        if not res then
          error(err or 'unknown failure!', 2)
        end
      end
    end
  })
  
  return assertion
end

return lust