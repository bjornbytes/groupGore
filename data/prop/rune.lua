local Rune = {}
Rune.name = 'Rune'
Rune.code = 'rune'

Rune.width = 32
Rune.height = 32

Rune.collision = {}
Rune.collision.shape = 'rectangle'
Rune.collision.static = true
Rune.collision.tag = 'rune'
Rune.collision.with = {
  player = function(self, other, dx, dy)
    if not self.timer and not player.ghosting then
      self.timer = 12
			self[self.effect](self, other)
			local t = {'refillAmmo', 'refillHealth', 'speedBoost'}
			self.effect = t[love.math.random(3)]
    end
  end
}

function Rune:activate()
  self.x = self.x - (self.width / 2)
  self.y = self.y - (self.height / 2)
  ctx.event:emit('collision.attach', {object = self})
  if ctx.view then ctx.view:register(self) end
end

function Rune:update()
  self.timer = timer.rot(self.timer)
  if self.timer == 0 then self.timer = false end
end

function Rune:draw()
  if not self.timer then
    love.graphics.setColor(0, 150, 0, 100)
    self.shape:draw('fill')
    love.graphics.setColor(0, 150, 0, 255)
    self.shape:draw('line')
  end
end

function Rune:refillAmmo(player)
	for i = 1, 5 do
		if player.slots[i].type == 'weapon' then
			f.exe(player.slots[i].refillAmmo, player.slots[i], player)
		end
		if ctx.id == player.id then
			ctx.event:emit('sound.play', {sound = 'reload', x = self.x, y = self.y})
		end
	end
end

function Rune:refillHealth(player)
	player.health = math.min(player.health + (player.maxHealth / 4), player.maxHealth)
end

function Rune:speedBoost(player)
	ctx.buffs:add(player, 'runeSpeedBoost')
end

return Rune
