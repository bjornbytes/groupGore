Particles = class()

function Particles:init()
  self.particles = {}
  self.depth = -100
  if ctx.view then ctx.view:register(self) end
  ctx.event:on('particle.create', f.cur(self.create, self))
end

function Particles:create(arg)
  local type = arg.kind
  
  for _ = 1, arg.count or 1 do
    local p = new(data.particle[type])
    
    p:activate()
    table.merge(arg.vars or {}, p)
    
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
