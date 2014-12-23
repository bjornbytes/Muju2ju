local tween = require 'lib/deps/tween/tween'

Player = class()
Player.code = 'player'

Player.width = 45
Player.height = 90

Player.depth = 2


----------------
-- Core
----------------
function Player:init()
  self.meta = {__index = self}

  self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.direction = 1
  self.speed = 0
  self.walkSpeed = 65

  self.maxHealth = 500
	self.health = self.maxHealth
	self.healthDisplay = self.health

  self.deathTimer = 0
  self.deathDuration = 7
  self.dead = false
  self.ghost = Ghost(self)
  self.ghostX = self.x
  self.ghostY = self.y

	self.juju = 10
	self.jujuTimer = 1
  self.jujuRate = 2

	self.selected = 1
  self.maxPopulation = 1
  self.minionCost = 10 -- For Debugging

  self.summonTimer = 0
  self.summonPrevTimer = self.summonTimer
  self.summonFactor = {value = 0}
  self.summonTweenDuration = .45
  self.summonTween = tween.new(self.summonTweenDuration, self.summonFactor, {value = 1}, 'inOutBack')
  self.summonTweenTime = 0
  self.summonTweenPrevTime = self.summonTweenTime

  self.depth = self.depth + love.math.random()
end

function Player:activate()
  self.animation = data.animation.muju()

  self.animation:on('complete', function(data)
    if data.state.name ~= 'death' and not data.state.loop then
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

function Player:draw()
	love.graphics.setColor(255, 255, 255)
	self.animation:draw(self.x, self.y)

  if self.dead then
    self.ghost:draw(self.ghostX, self.ghostY, self.ghostAngle)
  end
end


----------------
-- Behavior
----------------
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
    self.x = math.clamp(self.x + self.speed * tickRate, 0, ctx.map.width)
  end
end

function Player:slot(input)
  self.summonTweenPrevTime = self.summonTweenTime
  self.summonPrevTimer = self.summonTimer

  self.selected = input.selected or self.selected
  if input.stance and self.deck[self.selected].instance then
    self.deck[self.selected].instance.stance = Unit.stanceList[input.stance]
  end

  if not self.dead and not self.animation.state.blocking and input.summon and self.juju >= self.minionCost and self:getPopulation() < self.maxPopulation then
    self.summonTimer = self.summonTimer + tickRate
    self.summonTweenTime = math.min(self.summonTweenTime + tickRate, self.summonTweenDuration)

    if self.summonTimer >= 5 then
      if self:spend(self.minionCost) then
        ctx.net:emit('unitCreate', {id = ctx.units.nextId, owner = self.id, kind = self.deck[self.selected].code, x = math.round(self.x)})

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
  self.health = self.maxHealth
  self.dead = false
  self.ghost:deactivate()

  self.animation:set('resurrect')
end

function Player:spend(amount)
  return self.juju >= amount
end


----------------
-- Helper
----------------
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
      instance = nil,
      code = entry.code
    }

    table.each(data.unit[entry.code].abilities, function(code)
      self.deck[entry.code].upgrades[code] = {}
    end)

    self.deck[i] = self.deck[entry.code]
  end
end

function Player:getPopulation()
  return table.count(ctx.units:filter(function(unit) return unit.player == self end))
end

function Player:animate()
  if self.dead then return end

  self.animation:set(math.abs(self.speed) > self.walkSpeed / 4 and 'walk' or 'idle')
  self.animation.speed = self.animation.state.name == 'walk' and math.abs(self.speed / self.walkSpeed) or 1
  if self.speed ~= 0 then self.animation.flipped = math.sign(self.speed) > 0 end
end
