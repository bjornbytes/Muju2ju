local Vuju = extend(Minion)
Vuju.code = 'vuju'

Vuju.cost = 20
Vuju.cooldown = 6
Vuju.maxHealth = 70
Vuju.speed = 0

Vuju.damage = 17
Vuju.fireRate = 1.7
Vuju.attackRange = 125

function Vuju:activate()
	Minion.activate(self)

  -- Stats
	self.attackRange = 125 + ctx.upgrades.vuju.surge.level * 25
	self.damage = 30
	local inc = 7
	for i = 1, ctx.upgrades.vuju.charge.level do
		self.damage = self.damage + inc
		inc = inc + 3
	end

	self.curseRate = 8 - ctx.upgrades.vuju.condemn.level
	self.curseTimer = 0

  -- Animation
  self.animation = data.animation.vuju(self)
	self.animation.flipX = not ctx.player.animation.flipX
end

function Vuju:update()
	if self.animationState == 'death' then -- TODO 'blocking' animations
		self.dead = self.animationState == 'death'
		self.x = self.x + self.knockBack * tickRate * 3000
		self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
		self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
		self.offsety = self.y + self.height + 8 - math.abs(self.knockBackDisplay * 200)
		self.animation:update()
		self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
		return
	end

	Minion.update(self)

  -- Target Acquired
	self.target = ctx.target:closest(self, 'enemy')
	if self.target and self.fireTimer == 0 and self:inRange() then self:attack() end

  -- Animations
	self.animation.offsety = self.height + 8
	self.animation:update()
end

function Vuju:attack()
	if ctx.upgrades.vuju.condemn.level > 0 and self.curseTimer == 0 then
		self.target.damageReduction = .4 + (ctx.upgrades.vuju.condemn.level * .1)
		self.target.damageReductionDuration = 5
		self.target.damageAmplification = .33 * ctx.upgrades.vuju.soak.level
		self.target.damageAmplificationDuration = 5
		self.curseTimer = self.curseRate
  else
		local targets = {self.target}
		local damage = self.damage
		local ox, oy = self.target.x, 0
		for i = 1, math.max(1, 2 * ctx.upgrades.vuju.arc.level) do
			if i > #targets then break end
			targets[1]:hurt(damage)
			ctx.spells:add('lightning', {x = ox, y = oy, target = targets[1]})
			ox, oy = targets[1].x, targets[1].y
			damage = math.max(damage / 2, self.damage / 4)
			local newTargets = ctx.target:inRange(targets[1], 25 + (25 * ctx.upgrades.vuju.arc.level), 'enemy')
			if not newTargets then break end
			for j = 1, #newTargets do
				if not table.has(targets, newTargets[j]) then
					table.insert(targets, 1, newTargets[j])
					break
				end
			end
		end

		self.fireTimer = self.fireRate
	end

  self.animation:set('cast')
end

function Vuju:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
    self.animation:set('death')
		return true
	end
end

function Vuju:getCost()
	local upgradeCount = ctx.upgrades.vuju.surge.level + ctx.upgrades.vuju.charge.level + ctx.upgrades.vuju.condemn.level + ctx.upgrades.vuju.arc.level + ctx.upgrades.vuju.soak.level
	return self.cost + upgradeCount * 4
end

return Vuju
