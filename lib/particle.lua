Particles = class()

function Particles:init()
	self.particles = {}
	self.depth = -100
	if ovw.view then ovw.view:register(self) end
end

function Particles:create(type, vars)
	local p = {
		image = nil,
		scale = 1,
		alpha = 1,
		color = {255, 255, 255},
		x = 0,
		y = 0,
		angle = 0
	}
	
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
	table.with(self.particles, function(v, i)
		local p = table.merge(table.interpolate(v.type.initial, v.type.final, (v.type.duration - v.health - tickDelta) / v.type.duration), table.copy(v))
		local r, g, b = unpack(p.color)
		love.graphics.setColor(r, g, b, p.alpha * 255)
		if p.image then
			love.graphics.draw(p.image, p.x, p.y, p.angle, p.scale, p.scale, p.image:getWidth() / 2, p.image:getHeight() / 2)
		end
	end)
end