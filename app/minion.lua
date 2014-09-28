Minion = class()

Minion.width = 48
Minion.height = 48
Minion.depth = -10

function Minion:activate()
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
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
	self.scale = .5 + (r / 210)
	self.depth = self.depth - r / 30 + love.math.random() * (1 / 30)

  ctx.event:emit('view.register', {object = self})
end

function Minion:deactivate()
  ctx.event:emit('view.unreigster', {object = self})
end

function Minion:update()

  -- Rots and Lerps
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)

  -- Health and Speed Decay
	self:hurt(self.maxHealth * .02 * tickRate)
	self.speed = math.max(self.speed - .5 * tickRate, 20)

  -- Knockback
	self.x = self.x + self.knockBack * tickRate * 3000
	self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
	self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
end

function Minion:draw()
  self.animation:draw(self.x, self.y)
end

function Minion:inRange()
  if not self.target then return false end
  return math.abs(self.target.x - self.x) <= self.attackRange + self.target.width / 2
end

function Minion:hurt(amount)
	self.health = self.health - amount
	if self.health <= 0 then
    self:die()
		return true
	end
end

function Minion:die()
  if ctx.upgrades.muju.harvest.level > 0 then
    local x = love.math.random(1 + ctx.upgrades.muju.harvest.level, 3 + ctx.upgrades.muju.harvest.level * 2)
    if love.math.random() > .5 then
      ctx.spells:add('juju', {amount = x, x = minion.x, y = minion.y, vx = love.math.random(-35, 35)})
    else
      ctx.spells:add('juju', {amount = x / 2, x = minion.x, y = minion.y, vx = love.math.random(0, 45)})
      ctx.spells:add('juju', {amount = x / 2, x = minion.x, y = minion.y, vx = love.math.random(-45, 0)})
    end
  end

  ctx.minions:remove(self)
end

function Minion:move()
  if not self.target or self:inRange() then return end
  self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate
end
