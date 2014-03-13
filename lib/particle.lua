Particles = class()

function Particles:init()
	self.particles = {}
	self.depth = -10000
	if ovw.view then ovw.view:register(self) end
end

function Particles:create(type, vars)
	local p = {}
	setmetatable(p, {__index = data.particle[type]})
	
	p:activate()
	table.merge(vars or {}, p)
	
	table.insert(self.particles, p)

	return p
end

function Particles:update()
	for i = #self.particles, 1, -1 do
		local p = self.particles[i]
		p._prev = table.copy(p)
		if f.exe(p.update, p) then
			table.remove(self.particles, i)
		end
	end
end

function Particles:draw()
	table.each(self.particles, function(v)
		local p = table.interpolate(v._prev, v, tickDelta / tickRate)
		p:draw()
	end)
end