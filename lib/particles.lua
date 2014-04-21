Particles = class()

function Particles:init()
  self.particles = {}
  self.depth = -10000
  if ctx.view then ctx.view:register(self) end
  ctx.event:on('particle.create', f.cur(self.create, self))
end

function Particles:create(_data)
  local type = _data.kind
  
  for _ = 1, _data.count or 1 do
    local p = new(data.particle[type])
    
    p:activate()
    table.merge(_data.vars or {}, p)
    
    table.insert(self.particles, p)
  end
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
