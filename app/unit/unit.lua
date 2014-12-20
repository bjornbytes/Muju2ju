Unit = class()

Unit.classStats = {'health', 'damage', 'range', 'attackSpeed', 'speed'}

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
    self.abilities[i] = setmetatable({}, {__index = ability})
    f.exe(self.abilities[i].activate, self.abilities[i], self)
  end

  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.team = self.owner and self.owner.team or 0
  self.maxHealth = self.health
  self.stance = 'aggressive'

  if self.owner then self.owner.deck[self.class.code].instance = self end

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  self.buffs:update()

  for i = 1, 2 do
    f.exe(self.abilities[i].update, self.abilities[i], self)
  end

  if ctx.tag == 'server' then
    f.exe(self.stances[self.stance], self)
  end
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

function Unit:ability(index)
  local ability = self.abilities[index]
  f.exe(ability.use, ability, self)
end

function Unit:hurt(amount, source)
  if source then
    for i = 1, 2 do
      amount = f.exe(source.abilities[i].preHurt, source.abilities[i], self, amount) or amount
    end
  end

  self.health = self.health - amount

  if self.health <= 0 then
    self:die()
    return true
  end
end

function Unit:heal(amount, source)
  self.health = math.min(self.health + amount, self.maxHealth)
end

function Unit:die()
  if not self.shouldDestroy then
    local vx, vy = love.math.random(-35, 35), love.math.random(-300, -100)
    ctx.net:emit('jujuCreate', {id = ctx.jujus.nextId, x = math.round(self.x), y = math.round(self.y), team = self.owner and self.owner.team or 0, amount = 3 + love.math.random(0, 2), vx = vx, vy = vy})
    self.shouldDestroy = true
  end
end
