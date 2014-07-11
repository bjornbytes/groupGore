local PlasmaCannon = {}
PlasmaCannon.code = 'pulsecannon'

function PlasmaCannon:activate(charge)
	local weapon = data.weapon.pulsecannon
  self.speed = 1000 + (charge / weapon.maxCharge) * 2500
	self.damage = weapon.minDamage + (charge / weapon.maxCharge) * (weapon.maxDamage - weapon.minDamage)
	self.radius = 30 + (charge / weapon.maxCharge) * 120
  self.x, self.y = self.owner.x, self.owner,y
  self.angle = self.owner.angle
	self.ded = false

  local dx, dy = self.owner.class.handx * self.owner.class.scale, self.owner.class.handy * self.owner.class.scale
  self.x = self.x + math.dx(dx, self.angle) - math.dy(dy, self.angle)
  self.y = self.y + math.dy(dx, self.angle) + math.dx(dy, self.angle)
  
  dx, dy = weapon.tipx * weapon.scale, weapon.tipy * weapon.scale
  self.x = self.x + math.dx(dx, self.angle) - math.dy(dy, self.angle)
  self.y = self.y + math.dy(dx, self.angle) + math.dx(dy, self.angle)

  for _ = 1, 4 do
    ctx.event:emit('particle.create', {
      kind = 'spark',
      vars = {
        x = self.x,
        y = self.y,
        angle = self.angle + love.math.random() * 1.56 - .78
      }
    })
  end

  ctx.event:emit('particle.create', {
    kind = 'muzzleFlash',
    vars = {
      owner = self.owner.id,
      weapon = 'energyrifle'
    }
  })

  ctx.event:emit('sound.play', {sound = 'pulse', x = self.x, y = self.y})

  if ctx.collision:lineTest(self.owner.x, self.owner.y, self.x, self.y, {tag = 'wall'}) then
    ctx.spells:deactivate(self)
  end
end

function PlasmaCannon:update()
  if self.ded then return ctx.spells:deactivate(self) end

  self.prevx, self.prevy = self.x, self.y
  local dis = self.speed * tickRate
  local wall, d = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle), {tag = 'wall'})
  if wall then dis = d end
  local tx, ty = self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle)

  local target = ctx.collision:lineTest(self.x, self.y, tx, ty, {tag = 'player', fn = function(p) return p.team ~= self.owner.team end, first = true})
  self.x, self.y = tx, ty
  if target or wall then
		local targets = ctx.collision:circleTest(self.x, self.y, self.radius, {tag = 'player', fn = function() return p.team ~= self.owner.team end, all = true})
		table.each(self.targets, function(p)
			ctx.net:emit(evtDamage, {id = p.id, amount = self.damage, from = self.owner.id, tick = tick})
			ctx.buffs:add(p, 'plasmasickness')
		end)
		self.ded = true
  end
end

return PlasmaCannon
