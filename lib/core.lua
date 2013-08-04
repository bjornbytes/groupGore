local mt = {}
mt.__call = function(self, ...) return new(self, ...) end
mt.__tostring = function(self) return self._name and self._name or 'object' end

function class(name)
  local t = {}
  setmetatable(t, mt)
  return t
end

function new(class, ...)
  local self = {}
  setmetatable(self, table.merge({__index = class}, table.copy(getmetatable(class))))
  self.super = class
  f.exe(class.init, self, ...)
  return self
end