Player = class()

Player.width = 45
Player.height = 90

Player.walkSpeed = 65
Player.maxHealth = 100

Player.depth = -10

function Player:init()
	self.health = 100
	self.healthDisplay = self.health
	self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.environment.groundHeight - self.height
	self.prevx = self.x
	self.prevy = self.y
	self.speed = 0
	self.jujuRealm = 0
	self.juju = 30
	self.jujuTimer = 1
	self.dead = false
	self.minions = {'zuju'}
	self.minioncds = {0}
	self.selectedMinion = 1
	self.invincible = 0

	self.summonedMinions = 0
	self.hasMoved = false

	local joysticks = love.joystick.getJoysticks()
	for _, joystick in ipairs(joysticks) do
		if joystick:isGamepad() then self.gamepad = joystick break end
	end
	self.gamepadSelectDirty = false

  self.animation = data.animation.muju(self)

	ctx.view:register(self)
end

function Player:update()
	self.prevx = self.x
	self.prevy = self.y

  -- Global behavior
	self.invincible = timer.rot(self.invincible)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
	self.jujuTimer = timer.rot(self.jujuTimer, function()
		self.juju = self.juju + 1
		return 1
	end)
  self:slot()
	self:animate()
	
  -- Dead behavior
  if self.dead then
    self.ghost:update()
    self.jujuRealm = timer.rot(self.jujuRealm, function() self:spawn() end)
    return
  end

  -- Alive behavior
  self:move()
	self:hurt(self.maxHealth * .033 * tickRate)
end

function Player:paused()
  self.prevx = self.x
  self.prevy = self.y
  if self.ghost then
    self.ghost.prevx = self.ghost.x
    self.ghost.prevy = self.ghost.y
  end
end

function Player:draw()
	if math.floor(self.invincible * 4) % 2 == 0 then
		love.graphics.setColor(255, 255, 255)
		self.animation:draw()
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

	if key == ' ' then
		self:summon()
	end
end

function Player:gamepadpressed(gamepad, button)
	if gamepad == self.gamepad then
		if (button == 'a' or button == 'rightstick' or button == 'rightshoulder') then
      self:summon()
		end
	end
end

function Player:move()
  if self.animationState == 'summon' or self.animationState == 'death' or self.animationState == 'resurrect' then
    self.speed = 0
    return
  end

  local maxSpeed = self.walkSpeed
  if self.gamepad and math.abs(self.gamepad:getGamepadAxis('leftx')) > .5 then
    maxSpeed = self.walkSpeed * math.abs(self.gamepad:getGamepadAxis('leftx'))
  end
  if love.keyboard.isDown('left', 'a') or (self.gamepad and self.gamepad:getGamepadAxis('leftx') < -.5) then
    self.speed = math.lerp(self.speed, -maxSpeed, math.min(10 * tickRate, 1))
  elseif love.keyboard.isDown('right', 'd') or (self.gamepad and self.gamepad:getGamepadAxis('leftx') > .5) then
    self.speed = math.lerp(self.speed, maxSpeed, math.min(10 * tickRate, 1))
  else
    self.speed = math.lerp(self.speed, 0, math.min(10 * tickRate, 1))
  end

  if self.speed ~= 0 then self.hasMoved = true end
  self.x = math.clamp(self.x + self.speed * tickRate, 0, ctx.map.width)
end

function Player:slot()
  for i = 1, #self.minioncds do
		self.minioncds[i] = timer.rot(self.minioncds[i], function() ctx.hud.minions.extra[i] = 1 end)
	end

  if self.gamepad then
    local ltrigger = self.gamepad:getGamepadAxis('triggerleft') > .5
    local rtrigger = self.gamepad:getGamepadAxis('triggerright') > .5
    if not self.gamepadSelectDirty then
      if rtrigger then self.selectedMinion = self.selectedMinion + 1 end
      if ltrigger then self.selectedMinion = self.selectedMinion - 1 end
      if self.selectedMinion <= 0 then self.selectedMinion = #self.minions
      elseif self.selectedMinion > #self.minions then self.selectedMinion = 1 end
    end
    self.gamepadSelectDirty = rtrigger or ltrigger
  end
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
    if math.abs(self.speed) > self.walkSpeed / 2 then
      self.animation:set('walk')
    else
      self.animation:set('idle')
    end
  end

	if self.speed ~= 0 then self.animation.flipX = self.speed > 0 end
	self.animation:update()
end

function Player:spend(amount)
  if self.juju < amount then return false end
  self.juju = self.juju - amount
  return true
end

function Player:summon()
  if self.dead then return end
	local minion = data.minion[self.minions[self.selectedMinion]]
	local cooldown = self.minioncds[self.selectedMinion]
	local cost = minion:getCost()
	if cooldown == 0 and self:spend(cost) then
		ctx.minions:add(minion.code, {x = self.x + love.math.random(-20, 20)})
		self.minioncds[self.selectedMinion] = minion.cooldown * (1 - (.1 * ctx.upgrades.muju.flow.level))
		if ctx.upgrades.muju.refresh.level == 1 and love.math.random() < .15 then
			self.minioncds[self.selectedMinion] = 0
		end

    for i = 1, 15 do
      ctx.particles:add('dirt', {x = self.x, y = self.y + self.height})
    end

		self.summonedMinions = self.summonedMinions + 1

		self.animation:set('summon')
		local summonSound = love.math.random(1, 3)
		ctx.sound:play({sound = 'summon' .. summonSound})
	end
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

	-- Check whether or not to enter Juju Realm
	if self.health <= 0 and self.jujuRealm == 0 then

  	-- We jujuin'
		self.jujuRealm = 7
		self.dead = true
		self.ghost = GhostPlayer()

		self.animation:set('death')

		if self.gamepad and self.gamepad:isVibrationSupported() then
			self.gamepad:setVibration(1, 1, .5)
		end

		return true
	end
end

