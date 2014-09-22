PlayerDummy = extend(Player)

function PlayerDummy:activate()
  self.history = {}

  Player.activate(self)

  self.animation:set('summon')
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
  if self.history[#self.history].tick < t then
    local h1, h2 = self.history[#self.history - 1], self.history[#self.history]
    local factor = math.min(1 + ((t - h2.tick) / (h2.tick - h1.tick)), .1 / tickRate)
    local t = table.interpolate(h1, h2, factor)
    return t
  end

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

  if love.math.random() < .03 then
    self.animation:set('summon')
  end
end

function PlayerDummy:trace()
  table.insert(self.history, setmetatable({
    x = data.x,
    y = data.y,
    tick = data.tick
  }, self.meta))

  self.x, self.y = data.x, data.y
  self.health = data.health or self.health
  self.selectedMinion = data.selectedMinion or self.selectedMinion
end
