Particles = class()

function Particles:init()
	self.particles = {}
	self.depth = -10000
	if ovw.view then ovw.view:register(self) end
end

function Particles:create(type, vars)
	local p = {
		image = nil,
		shape = nil,
		scale = 1,
		alpha = 1,
		color = {255, 255, 255},
		x = 0,
		y = 0,
		speed = 0,
		angle = 0,
		length = 1
	}
	
	p.type = data.particle[type]
	p.health = p.type.duration
	table.merge(p.type.initial, p)
	table.merge(vars or {}, p)

	p.xstart = p.x
	p.ystart = p.y
	
	table.insert(self.particles, p)

	return p
end

function Particles:update()
	table.each(self.particles, function(p, i)
		p.health = p.health - tickRate
		if p.health <= 0 then table.remove(self.particles, i) end

		if p.speed and p.angle then
			p.x = p.x + math.dx(p.speed * tickRate, p.angle)
			p.y = p.y + math.dy(p.speed * tickRate, p.angle)
		end
	end)
end

local draws = {
	line = function(p)
		if p.lineWidth then love.graphics.setLineWidth(p.lineWidth) end
		local l = math.min(p.length, math.distance(p.x, p.y, p.xstart, p.ystart))
		love.graphics.line(p.x, p.y, p.x + math.dx(l, p.angle), p.y + math.dy(l, p.angle))
		if p.lineWidth then love.graphics.setLineWidth(1) end
	end
}

function Particles:draw()
	table.each(self.particles, function(v, i)
		local p = table.merge(table.interpolate(v.type.initial, v.type.final, (v.type.duration - v.health - tickDelta) / v.type.duration), table.copy(v))
		local r, g, b = unpack(p.color)
		love.graphics.setColor(r, g, b, p.alpha * 255)
		if p.image then
			love.graphics.draw(p.image, p.x, p.y, p.angle, p.scale, p.scale, p.image:getWidth() / 2, p.image:getHeight() / 2)
		elseif p.shape then
			draws[p.shape](p)
		end
	end)
end