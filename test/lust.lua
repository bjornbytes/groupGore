local lust = {}
lust.level = 0

function lust.describe(name, fn)
  local load = love.load
  local update = love.update
  love.update = function()
    love.event.pump()
    for e, a, b, c, d in love.event.poll() do
      if e == 'quit' then f.exe(love.quit) love.audio.stop() return
      else love.handlers[e](a, b, c, d) end
    end
    update()
  end
  love.load = function() end

  print(string.rep('\t', lust.level) .. name)
  lust.level = lust.level + 1
  fn()
  lust.level = lust.level - 1

  love.update = update
  love.load = load
end

function lust.test(name, fn)
  print(string.rep('\t', lust.level) .. name)
  lust.level = lust.level + 1
  f.exe(lust.before)
  local success, err = pcall(fn)
  if not success then
    print(string.rep('\t', lust.level) .. 'FAIL: ' .. err)
    error(name .. ' (' .. err .. ')', 0)
  else
    print(string.rep('\t', lust.level) .. 'PASS')
  end
  lust.level = lust.level - 1
  f.exe(lust.after)
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
