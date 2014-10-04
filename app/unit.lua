Unit = class()

Unit.depth = -10

function Unit:activate()
  if ctx.tag == 'server' then
    self.syncCounter = 0
    self.syncRate = 1

    self.rng = love.math.newRandomGenerator(self.id)

    self.target = nil
    self.fireTimer = 0
    self.damageReduction = 0
    self.damageReductionDuration = 0
    self.damageAmplification = 0
    self.damageAmplificationDuration = 0
    self.slow = 0
    self.knockBack = 0
    self.dead = false
  else
    self.history = NetHistory(self)
    
    -- Depth randomization / Fake3D
    local r = love.math.random(-20, 20)
    self.scale = (data.animation[self.code] and data.animation[self.code].scale or 1) + (r / 210)
    self.y = self.y + r
    self.depth = self.depth - r / 20 + love.math.random() * (1 / 20)
  end

  self.y = ctx.map.height - ctx.map.groundHeight - self.height
  self.health = self.maxHealth

  ctx.event:emit('view.register', {object = self})
end

function Unit:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Unit:update()
  if ctx.tag == 'server' then
    self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate)
    self.damageReductionDuration = timer.rot(self.damageReductionDuration, function() self.damageReduction = 0 end)
    self.damageAmplificationDuration = timer.rot(self.damageAmplificationDuration, function() self.damageAmplification = 0 end)
    self.slow = math.lerp(self.slow, 0, 1 * tickRate)
    self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)

    self.x = self.x + self.knockBack * tickRate * 3000
    if self.code == 'zuju' then
      self:hurt(self.maxHealth * .02 * tickRate)
      self.speed = math.max(self.speed - .5 * tickRate, 20)
    end

    self.animation:tick(tickRate)
  else
    --
  end
end

function Unit:draw()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t, true)
  local cur = self.history:get(t + 1, true)

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
  self.target = ctx.target:closest(self, 'shrine', 'player', 'enemy')
end

function Unit:inRange()
  if not self.target then return false end
  return math.abs(self.target.x - self.x) <= self.attackRange + self.target.width / 2
end

function Unit:move()
  if not self.target or self:inRange() then return end
  self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate * (1 - self.slow)
end

function Unit:hurt(amount)
  self.health = self.health - (amount + (amount * self.damageAmplification))
  if self.health <= 0 then
    self:die()
    return true
  end
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
