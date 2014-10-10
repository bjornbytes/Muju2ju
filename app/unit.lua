Unit = class()

Unit.depth = -10

Unit.cost = 5
Unit.cooldown = 5

function Unit:activate()
  if ctx.tag == 'server' then
    self.rng = love.math.newRandomGenerator(self.id)

    -- Time-based scaling
    local minutes = ctx.timer * tickRate / 60
    self.maxHealth = self.maxHealth + self.maxHealthPerMinute * minutes
    self.damage = self.damage + self.damagePerMinute * minutes

    -- Defensive Stats
    self.armor = 0
    self.flatArmor = 0
    self.tenacity = 0
    self.healAmplification = 0

    -- Attack Stats
    self.weaken = 0
    self.lifesteal = 0
    self.critChance = 0
    self.cleave = 0
    self.shred = 0

    -- Utility Stats
    self.cooldownReduction = 0

    -- Debuffs
    self.knockBack = 0

    self.target = nil
    self.attackTimer = 0
    self.dead = false
    self.buffs = {}
  else
    self.history = NetHistory(self)
    
    -- Depth randomization / Fake3D
    local r = love.math.random(-20, 20)
    self.scale = (data.animation[self.code] and data.animation[self.code].scale or 1) + (r / 210)
    self.y = self.y + r
    self.depth = self.depth - r / 20 + love.math.random() * (1 / 20)
  end

  self.team = self.owner and self.owner.team or 0
  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.health = self.maxHealth

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  if ctx.tag == 'server' then
    self.attackTimer = self.attackTimer - math.min(self.attackTimer, tickRate)
    self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)

    table.each(self.buffs, function(entries, stat)
      table.each(entries, function(entry, i)
        entry.timer = timer.rot(entry.timer, function() table.remove(entries, i) end)
      end)
    end)

    self.x = self.x + self.knockBack * tickRate * 3000

    self:hurt(self.maxHealth * .02 * tickRate)
    self.speed = math.max(self.speed - .5 * tickRate, 20)

    if self.animation then self.animation:tick(tickRate) end
  else
    --
  end
end

function Unit:draw()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t, true)
  local cur = self.history:get(t + 1, true)

  if not self.animationData then
    local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
    local p = ctx.players:get(ctx.id)
    local g = love.graphics

    g.setColor(self.team == p.team and {0, 255, 0} or {255, 0, 0})
    g.rectangle('fill', lerpd.x - lerpd.width / 2, lerpd.y, lerpd.width, lerpd.height)
  end

  if not cur.animationData or not prev.animationData then return end

  while cur.animationData.index == prev.animationData.index and cur.animationData.time < prev.animationData.time do
    cur.animationData.time = cur.animationData.time + 1
  end

  if prev.animationData.mixing and cur.animationData.mixing then
    while cur.animationData.mixTime < prev.animationData.mixTime do
      cur.animationData.mixTime = cur.animationData.mixTime + 1
    end
  end

  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)

  if lerpd.animationData then
    if prev.animationData.index ~= cur.animationData.index then
      lerpd.animationData = prev.animationData
    end

    self.animation:drawRaw(lerpd.animationData, lerpd.x, lerpd.y)
  end
end

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
  if source then
    amount = amount * (1 - source:getStat('weaken'))
    if love.math.random() < source.critChance then
      amount = amount * 2
    end
    amount = amount + (source.shred * self.maxHealth)
  end
  amount = amount - self.flatArmor
  amount = amount * (1 - self.armor)
  self.health = self.health - amount
  if source and source.lifesteal > 0 then
    source:heal(amount * source.lifesteal)
  end

  if self.health <= 0 then
    self:die()
    return true
  end
end

function Unit:heal(amount, source)
  amount = amount * (1 + self.healAmplification)
  self.health = math.min(self.health + amount, self.maxHealth)
end

function Unit:die()
  local vx, vy = love.math.random(-35, 35), love.math.random(-300, -100)
  ctx.net:emit('jujuCreate', {id = ctx.jujus.nextId, x = self.x, y = self.y, amount = 10, vx = vx, vy = vy})
  ctx.net:emit('unitDestroy', {id = self.id})
end

function Unit:getHealthbar()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
  return lerpd.x, lerpd.y, lerpd.health / lerpd.maxHealth
end

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

  tag = tag and self:getBuff(tag)
  if tag then
    tag.amout = amount
    tag.timer = timer
    tag.source = source
    return
  end

  table.insert(self.buffs[stat], {amount = amount, timer = timer, source = source, tag = tag})
end

function Unit:getBuff(tag)
  return next(table.filter(self.buffs[stat], function(buff) return buff.tag == tag end))
end

function Unit:getStat(stat)
  local base = self[stat]
  if type(base) ~= 'number' then return base end
  local val = base
  table.each(self.buffs[key], function(buff)
    local amount = buff.amount

    if type(amount) == 'string' and amount:match('%%') then
      local percent = tonumber(amount:match('%-?%d')) / 100
      amount = base * percent
    end

    val = val + amount
  end)

  return val
end
