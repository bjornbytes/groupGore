function class(x, ...)
  local t = {}
  setmetatable(t, {__index = x, __call = class})
  if x and x.init then x.init(t, ...) end
  return t
end