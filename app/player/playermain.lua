require 'app/player/player'

PlayerMain = extend(Player)

function PlayerMain:activate()
  self.prev = setmetatable({}, self.meta)
  self.input = PlayerInput(self)

  ctx.view.x = self.x - ctx.view.width / 2
  ctx.view.y = self.y - ctx.view.height / 2

  Player.activate(self)

  self.healthDisplay = self.health
end

function PlayerMain:get(t)
  return t == tick and self or self.prev
end

function PlayerMain:update()
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.ghostX = self.ghostX
  self.prev.ghostY = self.ghostY
  self.prev.ghostAngle = self.ghost.angle
  self.prev.healthDisplay = self.healthDisplay

  self.healthDisplay = math.lerp(self.healthDisplay, self.health, 5 * tickRate)

  self.input:update()
  local input = self.input:read()
  self:move(input)
  self:slot(input)

  ctx.net:send('input', input)

  Player.update(self)
end

function PlayerMain:draw()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  if self.prev.ghostAngle then lerpd.ghostAngle = math.anglerp(self.prev.ghostAngle or self.ghost.angle, self.ghost.angle, tickDelta / tickRate) end
  return Player.draw(lerpd)
end

function PlayerMain:getHealthbar()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  return lerpd.x, lerpd.y, self.health / lerpd.maxHealth, lerpd.healthDisplay / lerpd.maxHealth
end

function PlayerMain:trace(data)
  self.juju = data.juju

  self.x = data.x or self.x
  self.health = data.health and ((data.health / 255) * self.maxHealth) or self.health

  if self.ghost:contained() then
    self.ghostX = data.ghostX or self.ghostX
    self.ghostY = data.ghostY or self.ghostY
  end

  -- Discard inputs before the ack.
  while #self.input.list > 0 and self.input.list[1].tick < data.ack + 1 do
    table.remove(self.input.list, 1)
  end

  -- Server reconciliation: Apply inputs that occurred after the ack.
  for i = 1, #self.input.list do
    if not self.dead or (self.dead and self.ghost:contained()) then
      self:move(self.input.list[i])
    end
  end
end
