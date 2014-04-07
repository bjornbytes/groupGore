local new, class

local has = function(t, k)
  for i = 1, #t do if t[i] == k then return true end end
  return false
end

new = function(x, ...)
  local t = class(x)
  if t.init then
    t:init(...)
  end
  return t
end

class = function(x)
  local t = {}
  setmetatable(t, {__index = x, __call = new})
  return t
end

local Suite = class()
local Test = class()
local Assertion = class()

function Suite:init(name, fn)
  local tests = {}
  
  local t = {
    it = function(...) table.insert(tests, Test(name, ...)) end
  }
  setmetatable(t, {__index = _G, __newindex = _G})
  setfenv(fn, t)
  fn()
  
  print()
  local code = 0
  for i = 1, #tests do
    if not tests[i]:run(i) then code = 1 end
  end
  print()

  os.exit(code)
end

function Suite:addTest(...)
  table.insert(self.tests, Test(name, ...))
end

describe = Suite

---

function Test:init(suite, name, fn)
  self.suite = suite
  self.name = name
  self.fn = fn
end

function Test:run(idx)
  local t = {
    expect = function(...) return Assertion(...) end
  }
  setmetatable(t, {__index = _G, __newindex = _G})
  setfenv(self.fn, t)
  local success, err = xpcall(self.fn, function(e)
    return tostring(e)
  end)
  if not success then    
    local red = string.char(27) .. '[' .. tostring(31) .. 'm'
    if idx ~= 1 then io.write('\n') end
    io.write(red .. self.suite .. ' ' .. self.name .. ': ' .. err)
    if love then error(err, 0) end
  else
    local green = string.char(27) .. '[' .. tostring(32) .. 'm'
    io.write(green .. '.')
  end
  
  io.write(string.char(27) .. '[' .. tostring(0) .. 'm')
  
  return success  
end

---

local function isa(v, x)
  if type(x) == 'string' then return type(v) == x, tostring(v) .. ' is not a ' .. x end
  return getmetatable(v).__index == x, 'table is not a ' .. tostring(x)
end

local paths = {
  [''] = {'to'},
  to = {'not', 'have', 'equal', 'be'},
  ['not'] = {'be', 'have'},
  be = {'a', 'an', 'truthy', 'falsy', f = function(v, x)
    return table.eq(v, x), tostring(v) .. ' and ' .. tostring(x) .. ' are not strictly equal!'
  end},
  a = {f = isa},
  an = {f = isa},
  truthy = {f = function(v) return v, tostring(v) .. ' is not truthy!' end},
  falsy = {f = function(v) return not v, tostring(v) .. ' is not falsy!' end},
  equal = {f = function(v, x) return v == x, tostring(v) .. ' and ' .. tostring(x) .. ' are not equal!' end},
  have = {f = function(v, x) return v[x], 'table does not have key ' .. tostring(x)  end}
}

function Assertion:init(val)
  self.val = val
  self.negate = false
  self.action = ''
  
  setmetatable(self, {
    __index = function(t, k)
      if k == 'not' then rawset(t, 'negate', not rawget(t, 'negate')) end
      if has(paths[rawget(t, 'action')], k) then
        rawset(t, 'action', k)
      end
      return t
    end,
    __call = function(t, ...)
      if paths[t.action].f then
        local res, err = paths[t.action].f(t.val, ...)
        if t.negate and res or not res then
          error(err or 'unknown failure!', 0)
        end
      end
    end
  })
end