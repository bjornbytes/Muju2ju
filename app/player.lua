Player = class()
Player.code = 'player'

Player.width = 45
Player.height = 90

Player.walkSpeed = 65
Player.maxHealth = 100

Player.depth = -10

function Player:init()
  self.meta = {__index = self}

	self.health = 100
	self.healthDisplay = self.health
	self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
	self.speed = 0
	self.juju = 30
	self.jujuTimer = 1
  self.deathTimer = 0
  self.deathDuration = 7
	self.dead = false
	self.minions = {'zuju'}
	self.minioncds = {0}
	self.selectedMinion = 1
	self.invincible = 0

  self.depth = self.depth + love.math.random()

	self.summonedMinions = 0
	self.hasMoved = false
end

function Player:activate()
  self.animation = data.animation.muju(self)

  ctx.event:emit('view.register', {object = self})
end

function Player:update()

  -- Global behavior
	self.invincible = timer.rot(self.invincible)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
	self.jujuTimer = timer.rot(self.jujuTimer, function()
		self.juju = self.juju + 1
		return 1
	end)
	self:animate()
	
  -- Dead behavior
  if self.dead then
    self.ghost:update()
    self.deathTimer = timer.rot(self.deathTimer, function() ctx.event:emit(evtSpawn, {id = self.id}) end)
    return
  end
end

function Player:paused()
  --
end

function Player:draw()
	if math.floor(self.invincible * 4) % 2 == 0 then
		love.graphics.setColor(255, 255, 255)
		self.animation:draw(self.x, self.y)
	end
end

function Player:keypressed(key)
	for i = 1, #self.minions do
		if tonumber(key) == i then
			self.selectedMinion = i
			self.recentSelect = 1
			return
		end
	end
end

function Player:move(input)
  if self.dead then
    self.speed = 0
    return self.ghost:move(input)
  end

  local current = self.animation:current()
  if current and current.blocking then
    self.speed = 0
    return
  end

  self.speed = self.walkSpeed * input.x
  if self.speed ~= 0 then self.hasMoved = true end
  self.x = math.clamp(self.x + self.speed * tickRate, 0, ctx.map.width)
end

function Player:slot(input)
  for i = 1, #self.minioncds do
		self.minioncds[i] = timer.rot(self.minioncds[i], function()
      if ctx.hud then ctx.hud.minions.extra[i] = 1 end
    end)
	end

  if input.summon then
    local minion = data.minion[self.minions[input.minion]]
    local cooldown = self.minioncds[self.selectedMinion]

    if cooldown == 0 and self:spend(minion:getCost()) then
      ctx.net:emit(evtSummon, {id = self.id, index = input.minion})
    end
  end
end

function Player:die()
  self.deathTimer = self.deathDuration
  self.dead = true
  self.ghost = GhostPlayer(self)
  self.animation:set('death')
end

function Player:spawn()
  self.invincible = 2
  self.health = self.maxHealth
  self.dead = false
  self.ghost:despawn()
  self.ghost = nil

  self.animation:set('resurrect')
end

function Player:animate()
	if not self.dead then
    self.animation:set(math.abs(self.speed) > self.walkSpeed / 2 and 'walk' or 'idle')
  end

	if self.speed ~= 0 then self.animation.flipX = self.speed > 0 end
end

function Player:spend(amount)
  if self.juju < amount then return false end
  self.juju = self.juju - amount
  return true
end

function Player:summon(code)
  if self.dead then return end

  ctx.minions:add(code, {x = self.x + love.math.random(-20, 20), owner = self})

  -- Set cooldown
  self.minioncds[self.selectedMinion] = data.minion[code].cooldown * (1 - (.1 * ctx.upgrades.muju.flow.level))
  if ctx.upgrades.muju.refresh.level == 1 and love.math.random() < .15 then
    self.minioncds[self.selectedMinion] = 0
  end

  self.summonedMinions = self.summonedMinions + 1

  self.animation:set('summon')

  -- Juice
  --for i = 1, 15 do ctx.particles:add('dirt', {x = self.x, y = self.y + self.height}) end
  ctx.event:emit('sound.play', {sound = 'summon' .. (love.math.random(1, 3))})
end

function Player:hurt(amount, source)
	if self.invincible == 0 then
		self.health = math.max(self.health - amount, 0)
		if self.gamepad and self.gamepad:isVibrationSupported() then
			local l, r = .25, .25
			if source then
				if source.x > self.x then r = .5
				elseif source.x < self.x then l = .5 end
			end

			self.gamepad:setVibration(l, r, .25)
		end
	end

	-- Death
	if self.health <= 0 and self.deathTimer == 0 then
    ctx.net:emit(evtDeath, {id = self.id})
    return true
	end
end

function Player:atShrine()
  return math.abs(self.x - ctx.shrine.x) < self.width 
end

