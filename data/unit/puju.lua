local Puju = extend(Unit)
Puju.code = 'puju'

Puju.width = 64
Puju.height = 24
Puju.speed = 40
Puju.damage = 18
Puju.fireRate = 1.1
Puju.maxHealth = 65
Puju.attackRange = Puju.width / 2

Puju.buttRate = 4
Puju.buttDamage = 27
Puju.buttRange = Puju.attackRange * 1.25

function Puju:activate()
	Unit.activate(self)

  if ctx.tag == 'server' then
    self.maxHealth = self.maxHealth + 4 * ctx.units.enemyLevel ^ 1.1
    self.health = self.maxHealth
    self.damage = self.damage + .5 * ctx.units.enemyLevel
    self.buttDamage = self.damage * 1.5
    self.buttTimer = 1
  end

  -- Animation
  self.animation = data.animation.puju(self, {scale = self.scale})
	self.attackAnimation = 0
end

function Puju:update()
	Unit.update(self)

  -- Targeting
  if ctx.tag == 'server' then
    self.target = ctx.target:closest(self, 'shrine', 'player', 'enemy')
    if self.target and self.fireTimer == 0 and self:inRange() then self:attack() end
    self:move()

    self.buttTimer = timer.rot(self.buttTimer)
    self.animation.flipX = (self.target.x - self.x) > 0
    self.attackAnimation = timer.rot(self.attackAnimation)
  end

  -- Animation
	--self.animation.offsety = self.height / 2 + 5 * math.sin(tick * tickRate * 4)
end

function Puju:attack()
	self.fireTimer = self.fireRate

	if self.buttTimer == 0 and self.target.code ~= 'player' and self.target ~= ctx.shrine and self.rng:random() < .6 then
		return self:butt()
	end

	local damage = self.damage * (1 - self.damageReduction)
	if self.target:hurt(damage, self) then self.target = false end
  if not self.target then self.target = ctx.shrine end
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5})
	self.attackAnimation = 1
end

function Puju:butt()
	local targets = ctx.target:inRange(self, self.buttRange * 2, 'enemy')
	local damage = self.buttDamage * (1 - self.damageReduction)
	if #targets >= 2 then damage = damage / 2 end
	table.each(targets, function(target)
		if math.sign(self.target.x - self.x) == math.sign(target.x - self.x) then
			target:hurt(damage, self)
			local sign = math.sign(target.x - self.x)
			target.knockBack = sign * (.2 + self.rng:random() / 25)
		end
	end)
	self.buttTimer = self.buttRate
	self.animation:set('headbutt')
  ctx.event:emit('sound.play', {sound = 'combat', with = function(sound) sound:setVolume(.5) end})
  if not self.target then self.target = ctx.shrine end
end

function Puju:draw()
	local g = love.graphics

  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)

	g.setColor(255, 255, 255)
	--self.animation:draw(lerpd.x, lerpd.y)
	--[[if self.damageReduction > 0 then
		g.setColor(255, 255, 255, 200 * math.min(self.damageReductionDuration, 1))
		g.draw(data.media.graphics.curseIcon, lerpd.x, lerpd.y - 55, self.damageReductionDuration * 4, .5, .5, self.curseIcon:getWidth() / 2, self.curseIcon:getHeight() / 2)
	end]]

  local g = love.graphics
  g.setColor(255, 0, 0)
  g.rectangle('fill', lerpd.x - self.width / 2, lerpd.y, self.width, self.height)
end

return Puju
