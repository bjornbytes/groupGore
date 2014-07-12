Spell = class()

function Spell:mirrorOwner()
	self.x, self.y, self.angle = self.owner.x, self.owner.y, self.owner.angle
end

function Spell:move(length, options)
	options = options or {}
	local x, y, angle = options.x or self.x, options.y or self.y, options.angle or self.angle
	return x + math.dx(length, angle), y + math.dy(length, angle)
end

function Spell:movePlayerTo(player, x, y)
	player.x, player.y = x, y
	if player.inputs then
		table.insert(player.inputs, {
			tick = tick + 1,
			reposition = {
				x = player.x,
				y = player.y
			}
		})
	end
end

function Spell:movePlayer(player, length, options)
	options = options or {}
	local angle = options.angle or self.angle
	return Spell.movePlayerTo(player, player.x + math.dx(length, angle), player.y + math.dy(length, angle))
end

function Spell:moveOwnerTo(x, y)
	return Spell.movePlayerTo(self.owner, x, y)
end

function Spell:moveOwner(length, options)
	return Spell.movePlayer(self, self.owner, length, options)
end

function Spell:distanceTo(object, options)
	options = options or {}
	local x, y = options.x or self.x, options.y or self.y
	return math.distance(x, y, object.x, object.y)
end

function Spell:wallDistance(range)
	local x2, y2 = Spell.move(self, range, self.angle)
	local wall, distance = ctx.collision:lineTest(self.x, self.y, x2, y2, {tag = 'wall', first = true})
	return wall and distance or range
end

function Spell:rot(fn)
	self.timer = self.timer - tickRate
	if self.timer <= 0 then
		f.exe(fn)
		ctx.spells:deactivate(self)
		return true
	end
end

function Spell:enemiesInRadius(options)
	options = options or {}
	local x, y, r = options.x or self.x, options.y or self.y, options.radius or self.radius
	local function isEnemy(p) return p.team ~= self.team end
	return select(1, ctx.collision:circleTest(x, y, r, {tag = 'player', fn = isEnemy, all = true}))
end

function Spell:enemiesInLine(distance, options)
	options = options or {}
	local x, y, angle, all = options.x or self.x, options.y or self.y, options.angle or self.angle, options.all or false
	local x2, y2 = Spell.move(self, distance, options)
	local function isEnemy(p) return p.team ~= self.team end
	return select(1, ctx.collision:lineTest(x, y, x2, y2, {tag = 'player', fn = isEnemy, first = not all, all = all}))
end

function Spell:damage(enemies, amount)
	if not enemies then return end
	if enemies.id then enemies = {enemies} end
	amount = f.val(amount)

	table.each(enemies, function(enemy)
		ctx.net:emit(evtDamage, {id = enemy.id, from = self.owner.id, amount = amount(enemy), tick = tick})
	end)
end

function Spell:damageInLine(distance, amount, options)
	Spell.damage(self, Spell.enemiesInLine(self, distance, options), amount)
end

function Spell:damageInRadius(amount, options)
	Spell.damage(self, Spell.enemiesInRadius(self, options), amount)
end

function Spell:lerpInit(vars)
	self._prev = {}
	if not vars then vars = {'x', 'y'}
	for i = 1, #vars do self._prev[vars[i]] = 0 end
end

function Spell:lerpUpdate()
	table.map(self._prev, function(_, k) return self[k] end)
end

function Spell:lerpGet(...)
	local res = {}
	if #arg == 0 then arg = {'x', 'y'} end
	table.each(arg, function(x)
		table.insert(res, math.lerp(self._prev[x], self[x], tickDelta / tickRate))
	end)
	return unpack(res)
end

function Spell:drawCircle(how, options)
	options = options or {}
	love.graphics.circle(how, options.x or self.x, options.y or self.y, options.radius or self.radius)
end
