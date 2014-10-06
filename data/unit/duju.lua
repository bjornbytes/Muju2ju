local Puju = extend(Unit)
Puju.code = 'puju'

Puju.width = 64
Puju.height = 24

Puju.maxHealth = 75
Puju.maxHealthPerMinute = 8
Puju.damage = 11
Puju.damagePerMinute = 10
Puju.attackRange = 32
Puju.attackSpeed = 1.12
Puju.speed = 65

-- Spells?
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
    self:selectTarget()
    if self.target and self.attackTimer == 0 and self:inRange() then self:attack() end
    self:move()

    self.buttTimer = timer.rot(self.buttTimer)
    if self.target then
      self.animation.flipX = (self.target.x - self.x) > 0
    end
    self.attackAnimation = timer.rot(self.attackAnimation)
  end

  -- Animation
	--self.animation.offsety = self.height / 2 + 5 * math.sin(tick * tickRate * 4)
end

function Puju:attack()
	self.attackTimer = self.attackSpeed

  local buttable = isa(self.target, Unit)
	if self.buttTimer == 0 and buttable and self.rng:random() < .6 then
		return self:butt()
	end

	local damage = self.damage
	if self.target:hurt(damage, self) then self.target = false end
  if not self.target then self:selectTarget() end
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5})
	self.attackAnimation = 1
end

function Puju:butt()
	local targets = ctx.target:enemiesInRange(self, self.buttRange * 2, 'enemy')
	local damage = self.buttDamage
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
  if not self.target then self:selectTarget() end
end

return Puju
