require 'app/minions/minion'

Vuju = extend(Minion)

Vuju.code = 'vuju'
Vuju.cost = 20
Vuju.cooldown = 6
Vuju.maxHealth = 70
Vuju.speed = 0

Vuju.damage = 17
Vuju.fireRate = 1.7
Vuju.attackRange = 125

function Vuju:init(data)
	Minion.init(self, data)

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

  -- Animation Stuff ew
	self.skeleton = Skeleton({name = 'vuju', x = self.x, y = self.y + self.height, scale = .5})
	self.animator = Animator({
		skeleton = self.skeleton,
		mixes = {
			{from = 'idle', to = 'cast', time = .2},
			{from = 'cast', to = 'idle', time = .2},
			{from = 'cast', to = 'death', time = .2},
			{from = 'idle', to = 'death', time = .2}
		}
	})
	self.animationState = 'idle'
	self.animator:add(self.animationState, true)
	self.animator.state.onComplete = function(trackIndex)
		local name = self.animator.state:getCurrent(trackIndex).animation.name
		if name == 'death' then
			ctx.minions:remove(self)
		elseif name == 'cast' then
			self.animationState = 'idle'
			self.animator:add(self.animationState, true)
		end
	end
	self.skeleton.skeleton.flipX = not ctx.player.skeleton.skeleton.flipX
	self.animationSpeeds = table.map({
		idle = .4 * tickRate,
		cast = .8 * tickRate,
		death = .8 * tickRate
	}, f.val)
  self.draw = self.animator.draw
end

function Vuju:update()
	if self.animationState == 'death' then -- TODO 'blocking' animations
		self.dead = self.animationState == 'death'
		self.x = self.x + self.knockBack * tickRate * 3000
		self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
		self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
		self.skeleton.skeleton.x = self.x
		self.skeleton.skeleton.y = self.y + self.height + 8 - math.abs(self.knockBackDisplay * 200)
		self.animator:update(self.animationSpeeds[self.animationState]())
		self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
		return
	end

	Minion.update(self)

  -- Target Acquired
	self.target = ctx.target:closest(self, 'enemy')
	if self.target and self.fireTimer == 0 and self:inRange() then self:attack() end

  -- Animations
	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y + self.height + 8
	self.animator:update(self.animationSpeeds[self.animationState]())
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
			ctx.particles:add(Lightning, {x = ox, y = oy, target = targets[1]})
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

  if self.animationState ~= 'cast' then
    self.animationState = 'cast'
    self.animator:set(self.animationState, false)
  end
end

function Vuju:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
		if self.animationState ~= 'death' then -- TODO pls
			self.animationState = 'death'
			self.animator:set('death', false)
		end
		return true
	end
end

function Vuju:getCost()
	local upgradeCount = ctx.upgrades.vuju.surge.level + ctx.upgrades.vuju.charge.level + ctx.upgrades.vuju.condemn.level + ctx.upgrades.vuju.arc.level + ctx.upgrades.vuju.soak.level
	return self.cost + upgradeCount * 4
end
