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
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)

  if not lerpd.animationIndex then return end

  self.animation:draw(lerpd.x, lerpd.y)
end

function UnitClient:getHealthbar()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
  return lerpd.x, ctx.map.height - ctx.map.groundHeight - 80, lerpd.health / lerpd.maxHealth, self.health / lerpd.maxHealth
end
