Particles = class()

function Particles:init()
  self.particles = {}
  self.depth = -10000
  if ctx.view then ctx.view:register(self) end
end

function Particles:create(type, vars)
  local p = new(data.particle[type])
  
  p:activate()
  table.merge(vars or {}, p)
  
  table.insert(self.particles, p)

  return p
end

function Particles:update()
  for i = #self.particles, 1, -1 do
    local p = self.particles[i]
    if f.exe(p.update, p) then
      table.remove(self.particles, i)
    end
  end
end

function Particles:draw()
  table.with(self.particles, 'draw')
end
