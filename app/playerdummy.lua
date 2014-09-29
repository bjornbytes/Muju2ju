PlayerDummy = extend(Player)

local function historySearch(history, t)
  while history[1].tick < tick - 2 / tickRate and #history > 2 do
    table.remove(history, 1)
  end

  if history[#history].tick < t then
    local h1, h2 = history[#history - 1], history[#history]
    local factor = math.min(1 + ((t - h2.tick) / (h2.tick - h1.tick)), .25 / tickRate)
    return table.interpolate(h1, h2, factor)
  end

  for i = #history, 1, -1 do
    if history[i].tick <= t then return history[i] end
  end

  return history[1]
end

function PlayerDummy:activate()
  self.history = {}
  self.animationIndex = nil
  self.animationPrev = nil
  self.animationTime = 0
  self.animationPrevTime = 0
  self.animationAlpha = nil
  self.animationFlip = false

  Player.activate(self)
end

function PlayerDummy:update()
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
  self.speed = self:get(tick - (interp / tickRate)).speed
  self.deathTimer = timer.rot(self.deathTimer)
end

function PlayerDummy:get(t)
  if t == tick then return self end

  if #self.history < 2 then
    return setmetatable({
      tick = tick
    }, self.meta)
  end

  return historySearch(self.history, t)
end

function PlayerDummy:draw()
  local t = tick - (interp / tickRate)
  local prev = self:get(t)
  local cur = self:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
  
  if prev.animationAlpha and cur.animationAlpha and cur.animationAlpha < prev.animationAlpha then lerpd.animationAlpha = prev.animationAlpha end
  if cur.animationTime < prev.animationTime then lerpd.animationTime = prev.animationTime end
  self.animation:drawRaw(lerpd.animationIndex, lerpd.animationTime, lerpd.animationPrev, lerpd.animationPrevTime, lerpd.animationAlpha, lerpd.animationFlip, lerpd.x, lerpd.y)

  if self.dead then self.ghost:draw(lerpd.ghostX, lerpd.ghostY) end
end

function PlayerDummy:getHealthbar()
  local t = tick - (interp / tickRate)
  local lerpd = table.interpolate(self:get(t), self:get(t + 1), tickDelta / tickRate)
  return lerpd.x, lerpd.y, lerpd.health / lerpd.maxHealth
end

function PlayerDummy:trace(data)
  local animationMap = {
    [0] = nil,
    'idle', 'walk', 'summon', 'death', 'resurrect'
  }

  self.x = data.x or self.x
  self.y = data.y or self.y
  self.health = data.health or self.health
  self.animationTime = data.animationTime or self.animationTime
  self.animationPrevTime = data.animationPrevTime or self.animationPrevTime
  self.animationFlip = data.animationFlip
  self.ghostX = data.ghostX or self.ghostX
  self.ghostY = data.ghostY or self.ghostY
  if self.ghost and data.ghostAngle then self.ghost.angle = math.rad(data.ghostAngle) end

  table.insert(self.history, setmetatable({
    tick = data.tick,
    x = self.x,
    y = self.y,
    health = self.health,
    animationIndex = animationMap[data.animationIndex],
    animationPrev = animationMap[data.animationPrev],
    animationTime = self.animationTime,
    animationPrevTime = data.animationPrevTime,
    animationAlpha = data.animationAlpha,
    animationFlip = self.animationFlip,
    ghostX = self.ghostX,
    ghostY = self.ghostY
  }, self.meta))
end
