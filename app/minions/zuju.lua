require 'app/minions/minion'

Zuju = extend(Minion)

Zuju.code = 'zuju'
Zuju.cost = 12
Zuju.cooldown = 3

Zuju.speed = 45
Zuju.damage = 20
Zuju.fireRate = 1
Zuju.attackRange = Zuju.width / 2
Zuju.maxHealth = 80

function Zuju:init(data)
	Minion.init(self, data)

  -- Stats
	self.speed = self.speed + love.math.random(-10, 10)
	local healths = {[0] = 80, 125, 175, 235, 300, 400}
	self.maxHealth = healths[ctx.upgrades.zuju.fortify.level]
	self.health = self.maxHealth
	self.healthDisplay = self.health

  -- Animation Stuff ew
	self.skeleton = Skeleton({name = 'zuju', x = self.x, y = self.y + self.height + 8, scale = self.scale})
	self.animator = Animator({
		skeleton = self.skeleton,
		mixes = {
			{from = 'spawn', to = 'walk', time = .4},
			{from = 'walk', to = 'cast', time = .2},
			{from = 'cast', to = 'walk', time = .2},
			{from = 'cast', to = 'death', time = .2},
			{from = 'walk', to = 'death', time = .2}
		}
	})
	self.animationState = 'spawn'
	self.animationLock = true
	self.animator:add(self.animationState, false)
	self.animator.state.onComplete = function(trackIndex)
		local name = self.animator.state:getCurrent(trackIndex).animation.name
		if name == 'spawn' then
			self.animationLock = nil
			self.animationState = 'idle'
			self.animator:set(self.animationState, true)
		elseif name == 'death' then
			ctx.minions:remove(self)
		end
	end
	self.skeleton.skeleton.flipX = not ctx.player.skeleton.skeleton.flipX
	self.animationSpeeds = table.map({
		walk = .73 * tickRate,
		idle = .3 * tickRate,
		cast = .85 * tickRate,
		spawn = .85 * tickRate,
		death = .8 * tickRate
	}, f.val)
end

function Zuju:update()
	if self.animationState == 'death' or self.animationState == 'spawn' then -- TODO 'blocking' animations
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
	self.target = ctx.target:closest(self, 'enemy') or ctx.shrine
	if self.target ~= ctx.shrine and self.fireTimer == 0 and self:inRange() then self:attack() end

  -- Movement
  self:move()

  -- Animations
	if not self.animationLock then
    local inRange = self:inRange()
		if not inRange and self.animationState ~= 'walk' then
			self.animationState = 'walk'
			self.animator:set(self.animationState, true)
		elseif inRange and self.target == ctx.shrine and self.animationState ~= 'idle' then
			self.animationState = 'idle'
			self.animator:set(self.animationState, true)
		end
	end

	if self.animationState == 'walk' and self.target then
		self.skeleton.skeleton.flipX = (self.target.x - self.x) < 0
	end

	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y + self.height + 8 - math.abs(self.knockBackDisplay * 200)
	self.animator:update(self.animationSpeeds[self.animationState]())
end

function Zuju:attack()
  local damage = self:damage()

  -- Lifesteal
  local heal = math.min(damage, self.target.health) * .1 * ctx.upgrades.zuju.siphon.level
  self.health = math.min(self.health + heal, self.maxHealth)
  for i = 1, ctx.upgrades.zuju.siphon.level do
    ctx.particles:add(Lifesteal, {x = self.x, y = self.y})
  end

  -- The Works
  self.target:hurt(damage)
  self.fireTimer = self.fireRate

  -- Sound
  local pitch = 1 + love.math.random() * .2
  if love.math.random() > .5 then pitch = 1 / pitch end
  local sound = ctx.sound:play({sound = 'combat'})
  if sound then
    sound:setPitch(pitch)
    sound:setVolume(.5)
  end
end

function Zuju:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
		if self.animationState ~= 'death' then -- TODO pls
			self.animationLock = true
			self.animationState = 'death'
			self.animator:set('death', false)
		end
		return true
	end
end

function Zuju:damage()
	local damage = 20 + (5 + ctx.upgrades.zuju.empower.level) * ctx.upgrades.zuju.empower.level
	damage = damage + love.math.random(-3, 3)
	return damage
end

function Zuju:getCost()
	local upgradeCount = ctx.upgrades.zuju.empower.level + ctx.upgrades.zuju.fortify.level + ctx.upgrades.zuju.burst.level + ctx.upgrades.zuju.siphon.level + ctx.upgrades.zuju.sanctuary.level
	return self.cost + upgradeCount * 3
end
