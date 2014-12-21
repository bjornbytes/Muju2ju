Unit = class()

Unit.classStats = {'health', 'damage', 'range', 'attackSpeed', 'speed'}
Unit.stanceList = {'defensive', 'aggressive', 'follow'}
table.each(Unit.stanceList, function(stance, i) Unit.stanceList[stance] = i end)

Unit.width = 64
Unit.height = 64
Unit.depth = 3

----------------
-- Core
----------------
function Unit:activate()
  self.animation = data.animation[self.class.code]()

  self.animation:on('complete', function(data)
    if not data.state.loop then self.animation:set('idle') end
  end)

  self.buffs = UnitBuffs(self)

  self.abilities = {}
  for i = 1, 2 do
    local ability = data.ability[self.class.code][self.class.abilities[i]]
    assert(ability, 'Missing ability ' .. i .. ' for ' .. self.class.name)
    self.abilities[i] = ability()
    self.abilities[i].owner = self
  end

  self:abilityCall('activate')

  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.team = self.owner and self.owner.team or 0
  self.maxHealth = self.health
  self.stance = 'aggressive'
  self.dying = false

  if self.owner then self.owner.deck[self.class.code].instance = self end

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  if self.dying then return end

  self:abilityCall('update')

  self.buffs:preupdate()

  if ctx.tag == 'server' then
    f.exe(self.stances[self.stance], self)
  end

  self.buffs:postupdate()
end


----------------
-- Stances
----------------
Unit.stances = {}
function Unit.stances:defensive()
  local target = ctx.target:closest(self, 'enemy', 'player', 'unit')

  if target and self:inRange(target) then
    self:attack(target)
  else
    self.animation:set('idle')
  end
end

function Unit.stances:aggressive()
  local target = ctx.target:closest(self, 'enemy', 'shrine', 'player', 'unit')

  if self:inRange(target) then
    self:attack(target)
  else
    self:moveTowards(target)
  end
end

function Unit.stances:follow()
  self:moveTowards(self.owner)
end


----------------
-- Behavior
----------------
function Unit:inRange(target)
  return math.abs(target.x - self.x) <= self.range + target.width / 2 + self.width / 2
end

function Unit:moveTowards(target)
  if self:inRange(target) then
    self.animation:set('idle')
    return
  end

  self.x = self.x + self.speed * math.sign(target.x - self.x) * tickRate
  self.animation:set('walk')
  self.animation.flipped = self.x > target.x
end

function Unit:attack(target)
  if not self:inRange(target) then return end
  self.target = target
  self.animation:set('attack')
end

function Unit:useAbility(index)
  local ability = self.abilities[index]
  f.exe(ability.use, ability, self)
  ctx.net:emit('unitAbility', {id = self.id, tick = tick, ability = index})
end

Unit.hurt = f.empty
Unit.heal = f.empty

function Unit:die()
  self:abilityCall('die')
  self:abilityCall('deactivate')

  if self.owner then self.owner.deck[self.class.code].instance = nil end

  ctx.units:remove(self)
end


----------------
-- Helper
----------------
function Unit:get()
  return self -- overridden
end

function Unit:abilityCall(key, ...)
  for i = 1, 2 do
    local ability = self.abilities[i]
    f.exe(ability[key], ability, ...)
  end
end
