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
  self.buffs = UnitBuffs(self)

  self.skills = {}
  for i = 1, 2 do
    local skill = data.skill[self.class.code][self.class.skills[i]]
    assert(skill, 'Missing skill ' .. i .. ' for ' .. self.class.name)
    self.skills[i] = setmetatable({}, {__index = skill})
    f.exe(self.skills[i].activate, self.skills[i], self)
  end

  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.selected = false
  self.team = self.owner and self.owner.team or 0
  self.maxHealth = self.health
  self.stance = 'aggressive'

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  self.buffs:update()

  for i = 1, 2 do
    f.exe(self.skills[i].update, self.skills[i], self)
  end

  f.exe(self.stances[self.stance], self)
end


----------------
-- Stances
----------------
Unit.stances = {}
function Unit.stances:defensive()
  local target = ctx.target:closest(self, 'enemy', 'player', 'unit')

  if self:inRange(target) then
    self:attack(target)
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
end

function Unit:attack(target)
  if not self:inRange(target) then return end
  target:hurt(self.damage, self)
  self.animation:set('attack')
end

function Unit:hurt(amount, source)
  if source then
    for i = 1, 2 do
      amount = f.exe(source.skills[i].preHurt, source.skills[i], self, amount) or amount
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
