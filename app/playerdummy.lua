PlayerDummy = extend(Player)

function PlayerDummy:activate()
  self.history = NetHistory(self)
  Player.activate(self)
end

function PlayerDummy:update()
  self.healthDisplay = math.lerp(self.healthDisplay, self.health, 5 * tickRate)
  self.deathTimer = timer.rot(self.deathTimer)
  if self.dead then self.ghost:update() end
end

function PlayerDummy:get(t, raw)
  return self.history:get(t, raw)
end

function PlayerDummy:draw(onlyGhost)
  local t = tick - (interp / tickRate)
  local prev = self:get(t, true)
  local cur = self:get(t + 1, true)

  while cur.animationData.index == prev.animationData.index and cur.animationData.time < prev.animationData.time do
    cur.animationData.time = cur.animationData.time + 1
  end

  if prev.animationData.mixing and cur.animationData.mixing then
    while cur.animationData.mixTime < prev.animationData.mixTime do
      cur.animationData.mixTime = cur.animationData.mixTime + 1
    end
  end

  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)

  if not onlyGhost and lerpd.animationData then
    if prev.animationData.index ~= cur.animationData.index then
      lerpd.animationData = prev.animationData
    end

    self.animation:drawRaw(lerpd.animationData, lerpd.x, lerpd.y)
  end

  if lerpd.dead then
    local angle = math.anglerp(prev.ghostAngle, cur.ghostAngle, tickDelta / tickRate)
    self.ghost:draw(lerpd.ghostX, lerpd.ghostY, angle)
  end
end

function PlayerDummy:getHealthbar()
  local t = tick - (interp / tickRate)
  local lerpd = table.interpolate(self:get(t), self:get(t + 1), tickDelta / tickRate)
  return lerpd.x, lerpd.y, lerpd.health / lerpd.maxHealth, lerpd.healthDisplay / lerpd.maxHealth
end

function PlayerDummy:trace(data)
  if data.ghostAngle then data.ghostAngle = math.rad(data.ghostAngle) end

  local t = data.tick
  data.tick = nil
  if data.health then data.health = (data.health / 255) * self.maxHealth end
  table.merge(data, self)
  data.tick = t

  self.history:add(data)
end
