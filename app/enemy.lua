Enemy = class()

Enemy.depth = -10

function Enemy:activate()
	self.x = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height
  print(self.y)
	self.target = ctx.shrine
	self.fireTimer = 0

  -- Depth randomization / Fake3D
	local r = love.math.random(-20, 20)
	self.scale = 1 + (r / 210)
	self.y = self.y + r
	self.depth = self.depth - r / 20 + love.math.random() * (1 / 20)

	self.health = self.maxHealth
	self.healthDisplay = self.health
	self.damageReduction = 0
	self.damageReductionDuration = 0
	self.damageAmplification = 0
	self.damageAmplificationDuration = 0
	self.slow = 0

	ctx.view:register(self)
end

function Enemy:deactivate()
  ctx.view:unregister(self)
end

function Enemy:update()

  -- Rots and Lerps
	self.timeScale = 1 / (1 + ctx.upgrades.muju.distort.level * (ctx.player.dead and 1 or 0))
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
	self.damageReductionDuration = timer.rot(self.damageReductionDuration, function() self.damageReduction = 0 end)
	self.damageAmplificationDuration = timer.rot(self.damageAmplificationDuration, function() self.damageAmplification = 0 end)
	self.slow = math.lerp(self.slow, 0, 1 * tickRate)
end

function Enemy:inRange()
  if not self.target then return false end
  return math.abs(self.target.x - self.x) <= self.attackRange + self.target.width / 2
end

function Enemy:move()
  if not self.target or self:inRange() then return end
  self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate * self.timeScale * (1 - self.slow)
end

function Enemy:hurt(amount)
	self.health = self.health - (amount + (amount * self.damageAmplification))
	if self.health <= 0 then
    self:die()
		return true
	end
end

function Enemy:die()
  
  -- Juju!
	local x = love.math.random(14 + (ctx.enemies.level ^ .85) * .75, 20 + (ctx.enemies.level ^ .85))
	if love.math.random() > .5 then
		ctx.spells:add('juju', {amount = x, x = self.x, y = self.y, vx = love.math.random(-35, 35)})
	else
		ctx.spells:add('juju', {amount = x / 2, x = self.x, y = self.y, vx = love.math.random(0, 45)})
		ctx.spells:add('juju', {amount = x / 2, x = self.x, y = self.y, vx = love.math.random(-45, 0)})
	end

  ctx.enemies:remove(self)
end
