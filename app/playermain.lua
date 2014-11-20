PlayerMain = extend(Player)

function PlayerMain:activate()
  self.gamepadSelectDirty = false
  self.prev = setmetatable({}, self.meta)
  self.inputs = {}

  ctx.view.x = self.x - ctx.view.width / 2
  ctx.view.y = self.y - ctx.view.height / 2

  Player.activate(self)

  self.healthDisplay = self.health
end

function PlayerMain:get(t)
  return t == tick and self or self.prev
end

function PlayerMain:update()
  if ctx.input.gamepad then -- TODO
    local ltrigger = ctx.input.gamepad:getGamepadAxis('triggerleft') > .5
    local rtrigger = ctx.input.gamepad:getGamepadAxis('triggerright') > .5
    if not self.gamepadSelectDirty then
      if rtrigger then self.selectedMinion = self.selectedMinion + 1 end
      if ltrigger then self.selectedMinion = self.selectedMinion - 1 end
      if self.selectedMinion <= 0 then self.selectedMinion = #self.deck
      elseif self.selectedMinion > #self.deck then self.selectedMinion = 1 end
    end
    self.gamepadSelectDirty = rtrigger or ltrigger
  end

  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.ghostX = self.ghostX
  self.prev.ghostY = self.ghostY
  self.prev.ghostAngle = self.ghost.angle
  self.prev.healthDisplay = self.healthDisplay

  self.healthDisplay = math.lerp(self.healthDisplay, self.health, 5 * tickRate)

  local input = self:readInput()
  self:move(input)
  self:slot(input)

  ctx.net:send('input', input)

  Player.update(self)
end

function PlayerMain:draw(onlyGhost)
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  if self.prev.ghostAngle then lerpd.ghostAngle = math.anglerp(self.prev.ghostAngle or self.ghost.angle, self.ghost.angle, tickDelta / tickRate) end
  Player.draw(lerpd, onlyGhost)
end

function PlayerMain:getHealthbar()
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  return lerpd.x, lerpd.y, self.health / lerpd.maxHealth, lerpd.healthDisplay / lerpd.maxHealth
end

function PlayerMain:readInput()
  local t = {tick = tick}

  for i = 1, table.count(self.deck) do -- todo
    if love.keyboard.isDown(tostring(i)) then
      self.selectedMinion = i
    end
  end

  t.x = ctx.input:getAxis('x')
  t.y = ctx.input:getAxis('y')
  t.summon = love.keyboard.isDown(' ')--ctx.input:getAction('summon')
  t.minion = self.selectedMinion

  if self.summonTimer > 0 then
    t.x = 0
  end

  local current = self.animation:current()
  if current then
    if current.name == 'summon' then
      t.x = 0
    elseif current.name == 'resurrect' then
      t.x = 0
      t.summon = false
    end
  end
 
  local vx = ctx.input:getAxis('vx')
  ctx.view.vx = 1000 * vx

  table.insert(self.inputs, t)

  return t
end

function PlayerMain:trace(data)
  self.juju = data.juju

  self.x = data.x or self.x
  self.health = data.health and (data.health / 255 * self.maxHealth) or self.health

  if self.ghost:contained() then
    self.ghostX = data.ghostX or self.ghostX
    self.ghostY = data.ghostY or self.ghostY
  end

  -- Discard inputs before the ack.
  while #self.inputs > 0 and self.inputs[1].tick < data.ack + 1 do
    table.remove(self.inputs, 1)
  end

  -- Server reconciliation: Apply inputs that occurred after the ack.
  for i = 1, #self.inputs do
    if not self.dead or (self.dead and self.ghost:contained()) then
      self:move(self.inputs[i])
    end
  end
end
