require 'app/player/player'

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

function PlayerDummy:draw()
  local t = tick - (interp / tickRate)
  local prev = self:get(t)
  local cur = self:get(t + 1)
  local lerpd = table.interpolate(self:get(t), self:get(t + 1), tickDelta / tickRate)

  return Player.draw(lerpd)
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

  self.animation:set(data.animationIndex, {force = true})
  self.animation.flipped = data.flipped

  self.history:add(data)
end
