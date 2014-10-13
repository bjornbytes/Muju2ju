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
  if ctx.config.game.kind == 'survival' then
    self.x = ctx.map.width / 2
  else
    self.x = ctx.map.width * .2 + (.6 * (self.team == 2 and 1 or 0))
  end
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.ghost = Ghost(self)
  self.ghostX = self.x
  self.ghostY = self.y
	self.speed = 0
	self.juju = 30
	self.jujuTimer = 1
  self.deathTimer = 0
  self.deathDuration = 7
	self.dead = false
	self.minions = {'bruju'}
	self.minioncds = {0, 0}
	self.selectedMinion = 1
	self.invincible = 0

  self.depth = self.depth + love.math.random()

	self.summonedMinions = 0
	self.hasMoved = false
end

function Player:activate()
  self.animation = data.animation.muju(self)

  self:initDeck()

  ctx.event:emit('view.register', {object = self})
end

function Player:update()

  -- Global behavior
	self.invincible = timer.rot(self.invincible)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
	self:animate()
	
  -- Dead behavior
  if self.dead then
    self.health = 0
    self.ghost:update()
    self.deathTimer = timer.rot(self.deathTimer, function()
      self:spawn()
    end)
    return
  end
end

function Player:paused()
  --
end

function Player:draw()
	if math.floor(self.invincible * 4) % 2 == 0 then
		love.graphics.setColor(255, 255, 255)
    --love.graphics.rectangle('fill', self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
		self.animation:draw(self.x, self.y)
	end

  if self.dead then
    self.ghost:draw(self.ghostX, self.ghostY)
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
  if current and current.name == 'resurrect' then
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

  if not self.dead and not self.animation:blocking() and input.summon then
    local minion = data.unit[self.minions[input.minion]]
    local cooldown = self.minioncds[input.minion]

    if cooldown == 0 and self:spend(5) then
      ctx.net:emit('unitCreate', {id = ctx.units.nextId, owner = self.id, kind = minion.code, x = self.x, y = ctx.map.height - ctx.map.groundHeight - minion.height})
      self.minioncds[input.minion] = 5

      -- Juice
      for i = 1, 15 do ctx.event:emit('particles.add', {kind = 'dirt', x = self.x, y = self.y + self.height}) end
      ctx.event:emit('sound.play', {sound = 'summon' .. (love.math.random(1, 3))})
      self.animation:set('summon')
    end
  end
end

Player.hurt = f.empty
Player.heal = f.empty

function Player:die()
  self.deathTimer = self.deathDuration
  self.dead = true
  self.ghost:activate()
  self.animation:set('death')
end

function Player:spawn()
  self.invincible = 2
  self.health = self.maxHealth
  self.dead = false
  self.ghost:deactivate()

  self.animation:set('resurrect')
end

function Player:animate()
	if not self.dead then
    self.animation:set(math.abs(self.speed) > self.walkSpeed / 2 and 'walk' or 'idle')
  end

	if self.speed ~= 0 then self.animation.flipX = self.speed > 0 end
end

function Player:spend(amount)
  return self.juju >= amount
end

function Player:atShrine()
  local shrine = ctx.shrines:filter(function(shrine) return shrine.team == self.team end)[1]
  if not shrine then return false end
  return math.abs(self.x - shrine.x) < self.width 
end

function Player:initDeck()
  self.deck = {}
  for i = 1, #ctx.config.players[self.id].deck do
    local entry = ctx.config.players[self.id].deck[i]

    self.deck[entry.code] = {
      runes = table.map(entry.runes, function(rune) return setmetatable({level = 0}, runes[rune]) end),
      upgrades = {retaliation = true},
      cooldown = 0
    }
  end
end
