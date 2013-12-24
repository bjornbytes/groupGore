-- Math
function math.lerp(x1, x2, z) return x1 + (x2 - x1) * z end
function math.anglerp(d1, d2, z) return d1 + (math.anglediff(d1, d2) * z) end
function math.distance(x1, y1, x2, y2) return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ .5 end
function math.direction(x1, y1, x2, y2) return -math.atan2(x2 - x1, y2 - y1) end
function math.inside(px, py, rx, ry, rw, rh) return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh end
function math.anglediff(d1, d2) return math.rad((((math.deg(d2) - math.deg(d1) % 360) + 540) % 360) - 180) end
function math.hcora(cx, cy, cr, rx, ry, rw, rh) -- Hot circle on rectangle action.
  local hw, hh = rw / 2, rh / 2
  local cdx, cdy = math.abs(cx - (rx + hw)), math.abs(cy - (ry + hh))
  if cdx > hw + cr or cdy > hh + cr then return false end
  if cdx <= hw or cdy <= hh then return true end
  return (cdx - hw) ^ 2 + (cdy - hh) ^ 2 <= (cr ^ 2)
end
function math.hloca(x1, y1, x2, y2, cx, cy, cr) -- Hot line on circle action.
  local dx, dy = (x2 - x1), (y2 - y1)
  local a2 = math.abs(dx * (cy - y1) - dy * (cx - x1))
  local l = (dx * dx + dy * dy) ^ .5
  local h = a2 / l
  if not (h < cr) then return false end
  local t = (dx / l) * (cx - x1) + (dy / l) * (cy - y1)
  if t < 0 then return false end
  return l > t - ((cr ^ 2 - h ^ 2) ^ .5)
end
function math.hcoca(x1, y1, r1, x2, y2, r2) -- Hot circle on circle action.
  local dx, dy, r = x2 - x1, y2 - y1, r1 + r2
  return (dx * dx) + (dy * dy) < r * r
end
function math.hlola(x1, y1, x2, y2, x3, y3, x4, y4) -- Hot line on line action (boolean).
  local function s(x1, y1, x2, y2, x3, y3)
    return (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)
  end
  return s(x1, y1, x3, y3, x4, y4) ~= s(x2, y2, x3, y3, x4, y4) and s(x1, y1, x2, y2, x3, y3) ~= s(x1, y1, x2, y2, x4, y4)
end
function math.hlolax(x1, y1, x2, y2, x3, y3, x4, y4) -- Hot line on line action (intersection point).
  local a1, b1, a2, b2 = y2 - y1, x1 - x2, y4 - y3, x3 - x4
  local c1, c2 = a1 * x1 + b1 * y1, a2 * x3 + b2 * y3
  local d = a1 * b2 - a2 * b1
  if d == 0 then return false end
  local x, y = (b2 * c1 - b1 * c2) / d, (a1 * c2 - a2 * c1) / d
  if x < math.min(x1, x2) or x > math.max(x1, x2) or x < math.min(x3, x4) or x > math.max(x3, x4) then return false end
  if y < math.min(y1, y2) or y > math.max(y1, y2) or y < math.min(y3, y4) or y > math.max(y3, y4) then return false end
  return x, y
end
function math.hlora(x1, y1, x2, y2, rx, ry, rw, rh) -- Hot line on rectangle action (boolean).
  return math.hlola(x1, y1, x2, y2, rx, ry, rx + rw, ry)
    or math.hlola(x1, y1, x2, y2, rx, ry, rx, ry + rh)
    or math.hlola(x1, y1, x2, y2, rx + rw, ry, rx + rw, ry + rh)
    or math.hlola(x1, y1, x2, y2, rx, ry + rh, rx + rw, ry + rh)
end
function math.hlorax(x1, y1, x2, y2, rx, ry, rw, rh) -- Hot line on rectangle action (closest intersection point).
  local ps = {}
  ps[1] = {math.hlolax(x1, y1, x2, y2, rx, ry, rx + rw, ry)}
  ps[2] = {math.hlolax(x1, y1, x2, y2, rx, ry, rx, ry + rh)}
  ps[3] = {math.hlolax(x1, y1, x2, y2, rx + rw, ry, rx + rw, ry + rh)}
  ps[4] = {math.hlolax(x1, y1, x2, y2, rx, ry + rh, rx + rw, ry + rh)}
  local ds = table.map(ps, function(v, i) return v[1] and {math.distance(x1, y1, v[1], v[2]), i} or {math.huge, i} end)
  table.sort(ds, function(a, b) return a[1] < b[1] end)
  if ds[1][1] == math.huge then return false end
  return unpack(ps[ds[1][2]])
end

-- Table
function table.eq(t1, t2)
  if type(t1) ~= type(t2) then return false end
  if type(t1) ~= 'table' then return t1 == t2 end
  if #t1 ~= #t2 then return false end
  for k, _ in pairs(t1) do
    if not table.eq(t1[k], t2[k]) then return false end
  end
  return true
end

function table.copy(x)
  local t = type(x)
  if t ~= 'table' then return x end
  local y = {}
  for k, v in next, x, nil do y[k] = table.copy(v) end
  setmetatable(y, getmetatable(x))
  return y
end

function table.has(t, x, deep)
  local f = deep and table.eq or rawequal
  for _, v in pairs(t) do if f(v, x) then return true end end
  return false
end

function table.only(t, ks)
  local res = {}
  for _, k in pairs(ks) do res[k] = t[k] end
  return res
end

function table.except(t, ks)
  local res = table.copy(t)
  for _, k in pairs(ks) do res[k] = nil end
  return res
end

function table.with(t, f)
  if not t then return end
  for k, v in pairs(t) do f(v, k) end
end

function table.iwith(t, f)
  if not t then return end
  for k, v in ipairs(t) do f(v, k) end
end

function table.map(t, f)
  if not t then return end
  local res = {}
  table.with(t, function(v, k) res[k] = f(v, k) end)
  return res
end

function table.filter(t, f)
  return table.map(t, function(v, k) return f(v, k) and v or nil end)
end

function table.clear(t, v)
  table.with(t, function(_, k) t[k] = v end)
end

function table.merge(t1, t2)
  t2 = t2 or {}
  for k, v in pairs(t1) do t2[k] = table.copy(v) end
  return t2
end

function table.interpolate(t1, t2, z)
  local interp = table.copy(t1)
  for k, v in pairs(interp) do
    if t2[k] then
      if type(v) == 'table' then interp[k] = table.interpolate(t1[k], t2[k], z)
      elseif type(v) == 'number' then
        if k == 'angle' then interp[k] = math.anglerp(t1[k], t2[k], z)
        else interp[k] = math.lerp(t1[k], t2[k], z) end
      end
    end
  end
  return interp
end 

function table.deltas(t1, t2)
  if not t1 or not t2 then return t2 end
  return table.filter(t2, function(v, k) return v ~= t1[k] end)
end

function table.count(t)
  local ct = 0
  table.with(t, function() ct = ct + 1 end)
  return ct
end

function table.print(t, n)
  n = n or 0
  if n > 10 then return end
  if t == nil then print('nil') end
  if type(t) ~= 'table' then io.write(tostring(t)) io.write('\n')
  else
    for k, v in pairs(t) do
      io.write(string.rep('\t', n))
      io.write(k)
      if type(v) == 'table' then io.write('\n')
      else io.write('\t') end
      table.print(v, n + 1)
    end
  end
end

-- Byte
byte = {}
function byte.pack(...)
  local x = 0
  for i = 1, #arg do
    if arg[i] > 0 then x = x + (2 ^ (i - 1)) end
  end
  return x
end

function byte.unpack(x)
  local t = {}
  while x > 0 do
    table.insert(t, x % 2)
    x = math.floor(x / 2)
  end
  return t
end

function byte.extract(x, a, b)
  b = b or a
  x = x % (2 ^ (b + 1))
  for i = 1, a do
    x = math.floor(x / 2)
  end
  return x
end

function byte.insert(x, y, a, b)
  local res = x
  for i = a, b do
    res = (byte.extract(y, i - a) == byte.extract(x, i)) and res or (byte.extract(y, i - a) == 1 and res + (2 ^ i) or res - (2 ^ i))
  end
  return res
end

function byte.explode(x, l)
  local res = {}
  for i = 0, l - 1 do
    res[i + 1] = byte.extract(x, i)
  end
  return unpack(res)
end

-- Functions
f = {}
f.empty = function() end
f.exe = function(x, ...) if x then x(...) end end
f.ego = function(f) return function(x, ...) x[f](x, ...) end end
f.egoexe = function(f) return function(x, ...) if x[f] then x[f](x, ...) end end end

-- Timing
timer = {}
timer.start = function() _t1 = love.timer.getMicroTime() end
timer.delta = function() return love.timer.getMicroTime() - _t1 end
timer.rot = function(val, f) if not val or val == 0 then return val end if val < tickRate then f() return 0 end return val - tickRate end

-- String
string.capitalize = function(s) s = ' ' .. s return s:gsub('(%s%l)', string.upper) end

-- Class
function class(x, ...)
  local t = {}
  setmetatable(t, {__index = x, __call = class})
  if x and x.init then x.init(t, ...) end
  return t
end