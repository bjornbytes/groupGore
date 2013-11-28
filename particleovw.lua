Particles = {}

Particles.particles = {}

function Particles:create(type, vars)
	local p = {}
	
	p.type = data.particle[type]
	p.health = p.type.duration
	table.merge(p.type.initial, p)
	table.merge(vars or {}, p)
	
	table.insert(self.particles, p)
	
	return p
end

function Particles:update()
	table.with(self.particles, function(p, i)
		p.health = p.health - tickRate
		if p.health <= 0 then table.remove(self.particles, i) end
	end)
end

function Particles:draw()
	table.with(self.particles, function(p, i)
		local interp = table.interpolate(p.type.initial, p.type.final, (p.type.duration - p.health - tickDelta) / p.type.duration)
		love.graphics.setColor(255, 0, 0)
		love.graphics.circle('fill', 400, 300, interp.size)
	end)
end