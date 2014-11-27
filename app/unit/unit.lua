Unit = class()

Unit.width = 64
Unit.height = 64
Unit.depth = 3

----------------
-- Core
----------------
function Unit:activate()
  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.team = self.owner and self.owner.team or 0

  self.maxHealth = self.class.health
  self.health = self.maxHealth

  self.skills = {}
  for i = 1, 2 do
    local skill = data.skills[self.code][self.class.skills[i]]
    assert(skill, 'Missing skill ' .. i .. ' for ' .. self.class.name)
    self.skills[i] = setmetatable({}, {__index = skill})
    f.exe(self.skills[i].activate, self.skills[i], self)
  end

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  --
end


----------------
-- Behavior
----------------
function Unit:selectTarget()
  self.target = ctx.target:closest(self, 'enemy', 'shrine', 'player', 'unit')
end

function Unit:isTargetable(other)
  return true
end

function Unit:inRange()
  if not self.target then return false end
  return math.abs(self.target.x - self.x) <= self.attackRange + self.target.width / 2
end

function Unit:move()
  if not self.target or self:inRange() then return end
  self.x = self.x + self:getStat('speed') * math.sign(self.target.x - self.x) * tickRate
end

function Unit:hurt(amount, source)
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


----------------
-- Stats
----------------
function Unit:applyUpgrades()
  local base = data.unit[self.code]
  local runes = self.owner.deck[self.code].runes
  
  table.each(runes, function(rune)
    local level = rune.level
    if level > 0 then
      table.each(rune.values, function(levels, stat)
        local value = levels[level]
        if type(value) == 'number' then
          self[stat] = self[stat] + value
        elseif type(value) == 'string' and value:match('%%') then
          local original = base[stat]
          local percent = tonumber(value:match('%-?%d')) / 100
          self[stat] = self[stat] + original * percent
        end
      end)
    end
  end)
end

function Unit:addBuff(stat, amount, timer, source, tag)
  self.buffs[stat] = self.buffs[stat] or {}

  if tag then
    local buff = self:getBuff(stat, tag)
    if buff then
      buff.amount = amount
      buff.timer = timer
      buff.source = source
      return
    end
  end

  table.insert(self.buffs[stat], {amount = amount, timer = timer, source = source, tag = tag})
end

function Unit:getBuff(stat, tag)
  if not self.buffs[stat] then return end
  for _, buff in pairs(self.buffs[stat]) do 
    if buff.tag == tag then return buff end
  end
end

function Unit:getStat(stat)
  local base = self[stat]
  if type(base) ~= 'number' then return base end
  local val = base
  table.each(self.buffs[stat], function(buff)
    local amount = buff.amount

    if type(amount) == 'string' and amount:match('%%') then
      local percent = tonumber(amount:match('%-?%d')) / 100
      amount = base * percent
    end

    val = val + amount
  end)

  return val
end
