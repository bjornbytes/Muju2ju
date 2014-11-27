local tween = require 'lib/deps/tween/tween'

Player = class()
Player.code = 'player'

Player.width = 45
Player.height = 90

Player.walkSpeed = 65
Player.maxHealth = 500

Player.depth = 3

function Player:init()
  self.meta = {__index = self}

	self.health = self.maxHealth
	self.healthDisplay = self.health
  self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.direction = 1
  self.ghost = Ghost(self)
  self.ghostX = self.x
  self.ghostY = self.y
	self.speed = 0
	self.juju = 10
	self.jujuTimer = 1
  self.deathTimer = 0
  self.deathDuration = 7
	self.dead = false
	self.selectedMinion = 1
	self.invincible = 0
  self.summonTimer = 0
  self.summonPrevTimer = self.summonTimer
  self.summonFactor = {value = 0}
  self.summonTweenDuration = .45
  self.summonTween = tween.new(self.summonTweenDuration, self.summonFactor, {value = 1}, 'inOutBack')
  self.summonTweenTime = 0
  self.summonTweenPrevTime = self.summonTweenTime
  self.minionCost = 10 -- For Debugging

  self.maxPopulation = 1

  self.depth = self.depth + love.math.random()

	self.summonedMinions = 0
	self.hasMoved = false
end

function Player:activate()
  self.animation = data.animation.muju()

  self.animation:on('complete', function(data)
    if not data.state.loop then
      self.animation:set('idle', {force = true})
    end
  end)

  if ctx.config.game.gameType == 'survival' then
    self.x = ctx.map.width / 2
  else
    self.x = ctx.map.width * (.2 + (.6 * (self.team == 2 and 1 or 0)))
  end

  self:initDeck()

  ctx.event:emit('view.register', {object = self})
end

function Player:update()

  -- Global behavior
	self.invincible = timer.rot(self.invincible)
  local old = self.maxHealth
  self.maxHealth = math.round(Player.maxHealth + 20 * (tick * tickRate / 60))
  if self.health > 0 then self.health = self.health + (self.maxHealth - old) end
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
		self.animation:draw(self.x, self.y)
	end

  if self.dead then
    self.ghost:draw(self.ghostX, self.ghostY, self.ghostAngle)
  end
end

function Player:keypressed(key)
	for i = 1, #self.deck do
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

  if self.animation.state.name == 'resurrect' or input.summon then
    self.speed = 0
    return
  end

  if not input.summon then
    self.speed = self.walkSpeed * input.x
    if self.speed ~= 0 then self.hasMoved = true end
    self.x = math.clamp(self.x + self.speed * tickRate, 0, ctx.map.width)
  end
end

function Player:slot(input)
  self.summonTweenPrevTime = self.summonTweenTime
  self.summonPrevTimer = self.summonTimer

  if not self.dead and not self.animation.state.blocking and input.summon and self.juju >= self.minionCost and self:getPopulation() < self.maxPopulation then
    self.summonTimer = self.summonTimer + tickRate
    self.summonTweenTime = math.min(self.summonTweenTime + tickRate, self.summonTweenDuration)

    if self.summonTimer >= 5 then
      local minion = data.unit[self.deck[input.minion].code]

      if self:spend(self.minionCost) then
        ctx.net:emit('unitCreate', {id = ctx.units.nextId, owner = self.id, kind = minion.code, x = math.round(self.x)})

        -- Juice
        for i = 1, 15 do ctx.event:emit('particles.add', {kind = 'dirt', x = self.x, y = self.y + self.height}) end
        ctx.event:emit('sound.play', {sound = 'summon' .. (love.math.random(1, 3))})
        self.animation:set('summon')

        self.summonTimer = 0
      end
    end
  else
    self.summonTimer = 0
    self.summonTweenTime = math.max(self.summonTweenTime - tickRate, 0)
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
      upgrades = {},
      cooldown = 0,
      code = entry.code
    }

    self.deck[i] = self.deck[entry.code]
  end
end

function Player:getPopulation()
  return table.count(table.filter(ctx.units.objects, function(unit) return unit.owner == self end))
end

function Player:animate()
  if self.dead then return end

  self.animation:set(math.abs(self.speed) > self.walkSpeed / 4 and 'walk' or 'idle')
  self.animation.speed = self.animation.state.name == 'walk' and math.abs(self.speed / self.walkSpeed) or 1
  if self.speed ~= 0 then self.animation.flipped = math.sign(self.speed) > 0 end
end
