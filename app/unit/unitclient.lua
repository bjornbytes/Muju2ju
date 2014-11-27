require 'app/unit/unit'

UnitClient = extend(Unit)

function UnitClient:activate()
  self.history = NetHistory(self)
  self.createdAt = tick

  return Unit.activate(self)
end

function UnitClient:draw()
  local t = tick - (interp / tickRate)
  if t < self.createdAt then return end
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

function UnitClient:getHealthbar()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
  return lerpd.x, ctx.map.height - ctx.map.groundHeight - 80, lerpd.health / lerpd.maxHealth, self.health / lerpd.maxHealth
end
