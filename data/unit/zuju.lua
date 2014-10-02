local Zuju = extend(Unit)
Zuju.code = 'zuju'

Zuju.width = 48
Zuju.height = 48

Zuju.cost = 12
Zuju.cooldown = 3

Zuju.speed = 45
Zuju.damage = 20
Zuju.fireRate = 1
Zuju.attackRange = Zuju.width / 2
Zuju.maxHealth = 80

function Zuju:activate()
	Unit.activate(self)

  -- Stats
	self.speed = self.speed + self.rng:random(-10, 10)
  self.maxHealth = 80
	self.health = self.maxHealth
	self.healthDisplay = self.health

  -- Animation
  self.animation = data.animation.zuju(self, {scale = self.scale})
	self.animation.flipX = not self.owner.animation.flipX
end

function Zuju:update()
	if self.animation:blocking() then
		self.dead = self.animation:current().name == 'death'
		self.x = self.x + self.knockBack * tickRate * 3000
		self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
		self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
		self.animation.offsety = self.height + 8 - math.abs(self.knockBackDisplay * 200)
		self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
    if not ctx.id then self.animation:tick(tickRate) end
		return
	end

	Unit.update(self)

  -- Target Acquired
	self.target = ctx.target:closest(self, 'enemy') or ctx.shrine
	if self.target ~= ctx.shrine and self.fireTimer == 0 and self:inRange() then self:attack() end

  -- Movement
  if ctx.tag == 'server' then self:move() end

  -- Animations
  if not self:inRange() then
    self.animation:set('walk')
  elseif self.target == ctx.shrine then
    self.animation:set('idle')
  end

  local current = self.animation:current()
	if current and current.name == 'walk' and self.target then
		self.animation.flipX = (self.target.x - self.x) < 0
	end

  self.animation.offsety = self.height + 8 - math.abs(self.knockBackDisplay * 200)
  if not ctx.id then self.animation:tick(tickRate) end
end

function Zuju:draw()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
  self.animation:draw(lerpd.x, lerpd.y)
end

function Zuju:attack()
  local damage = self:damage()

  -- The Works
  self.target:hurt(damage)
  self.fireTimer = self.fireRate

  -- Sound
  ctx.event:emit('sound.play', {sound = 'combat', volume = .5, with = function(sound)
    local pitch = 1 + love.math.random() * .2
    if love.math.random() > .5 then pitch = 1 / pitch end
    sound:setPitch(pitch)
  end})
end

function Zuju:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
    self.animation:set('death')
		return true
	end
end

function Zuju:die()
  Unit.die(self)
end

function Zuju:damage()
	local damage = 20
	return damage
end

function Zuju:getCost()
  return 12
end

return Zuju
