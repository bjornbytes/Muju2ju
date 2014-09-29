PlayerDummy = extend(Player)

function PlayerDummy:activate()
  self.history = {}

  Player.activate(self)
end

function PlayerDummy:update()
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
	self:animate()

  if self.dead then
    self.ghost:update(true)
    self.deathTimer = timer.rot(self.deathTimer)
  end
end

function PlayerDummy:get(t)
  if t == tick then return self end

  if #self.history < 2 then
    return setmetatable({
      x = self.x,
      y = self.y,
      tick = tick
    }, self.meta)
  end

  while self.history[1].tick < tick - 1 / tickRate and #self.history > 2 do
    table.remove(self.history, 1)
  end

  -- Extrapolate if needed
  --[[if self.history[#self.history].tick < t then
    local h1, h2 = self.history[#self.history - 1], self.history[#self.history]
    local factor = math.min(1 + ((t - h2.tick) / (h2.tick - h1.tick)), .1 / tickRate)
    local t = table.interpolate(h1, h2, factor)
    return t
  end]]

  -- Search backwards through history until we find something.
  for i = #self.history, 1, -1 do
    if self.history[i].tick <= t then return self.history[i] end
  end

  return self.history[1]
end

function PlayerDummy:draw()
  local t = tick - (interp / tickRate)
  local lerpd = table.interpolate(self:get(t), self:get(t + 1), tickDelta / tickRate)
  Player.draw(lerpd)
end

function PlayerDummy:drawPosition()
  local t = tick - (interp / tickRate)
  local prev, cur = self:get(t), self:get(t + 1)
  return math.lerp(prev.x, cur.x, tickDelta / tickRate), math.lerp(prev.y, cur.y, tickDelta / tickRate)
end

function PlayerDummy:trace(data)
  if data.dead then
    if self.ghost then
      self.ghost.prevx = self.ghost.x
      self.ghost.prevy = self.ghost.y
      self.ghost.x = data.x
      self.ghost.y = data.y
    end
  else
    self.x, self.y = data.x, data.y
    self.health = data.health or self.health
    self.speed = data.speed or self.speed
  end

  table.insert(self.history, setmetatable({
    x = self.x,
    y = self.y,
    tick = data.tick
  }, self.meta))
end
