Minion = class()

Minion.width = 48
Minion.height = 48
Minion.depth = -10

function Minion:init(data)
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height
	self.target = nil
	self.fireTimer = 0
	self.dead = false
	self.health = self.maxHealth
	self.healthDisplay = self.health
	self.knockBack = 0
	self.knockBackDisplay = 0

  -- Depth randomization / Fake3D
	local r = love.math.random(-20, 20)
	self.y = self.y + r
	local scale = .5 + (r / 210)
	self.depth = self.depth - r / 30 + love.math.random() * (1 / 30)

	table.merge(data, self)
	ctx.view:register(self)
end

function Minion:update()

  -- Rots and Lerps
	self.timeScale = 1 / (1 + ctx.upgrades.muju.distort.level * (ctx.player.dead and 1 or 0))
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)

  -- Health and Speed Decay
	self:hurt(self.maxHealth * .02 * tickRate)
	self.speed = math.max(self.speed - .5 * tickRate, 20)

  -- Knockback
	self.x = self.x + self.knockBack * tickRate * 3000
	self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
	self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
end

function Minion:inRange()
  if not self.target then return false end
  return math.abs(self.target.x - self.x) <= self.attackRange + self.target.width / 2
end

function Minion:hurt(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		ctx.minions:remove(self)
		return true
	end
end

function Minion:move()
  if self:inRange() then return end
  self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate * self.timeScale
end
