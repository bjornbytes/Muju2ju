require 'app/unit/unit'

local g = love.graphics

UnitClient = extend(Unit)

function UnitClient:activate()
  self.history = NetHistory(self)
  self.createdAt = tick
  self.backCanvas = g.newCanvas(200, 200)
  self.canvas = g.newCanvas(200, 200)
  self.eventQueue = {}
  
  self.depth = self.depth + love.math.random()

  return Unit.activate(self)
end

function UnitClient:update()
  local t = tick - (interp / tickRate)
  local state = self.history:get(t)
  table.merge(state, self)

  while #self.eventQueue > 0 and self.eventQueue[1].tick <= t do
    local item = self.eventQueue[1]

    if item.kind == 'ability' then
      self:useAbility(item.ability)
    elseif item.kind == 'death' then
      self:die()
    end

    table.remove(self.eventQueue, 1)
  end

  return Unit.update(self)
end

function UnitClient:draw()
  local t = tick - (interp / tickRate)
  if t < self.createdAt then return end
  local lerpd = self:lerp()

  local animationIndex = self.history:get(t + 1, true).animationIndex
  if not animationIndex then return end

  self.animation:set(animationIndex, {force = true})
  self.animation.flipped = lerpd.flipped

  if self.player.team == ctx.players:get(ctx.id).team then
    self.canvas:clear(0, 255, 0, 0)
    self.backCanvas:clear(0, 255, 0, 0)
    g.setColor(0, 255, 0)
  else
    self.canvas:clear(255, 0, 0, 0)
    self.backCanvas:clear(255, 0, 0, 0)
    g.setColor(255, 0, 0)
  end

  local shader = data.media.shaders.colorize
  self.canvas:renderTo(function()
    g.setShader(shader)
    self.animation:draw(100, 100)
    g.setShader()
  end)

  local selected = self.player.deck[self.class.code].instance == self
  data.media.shaders.horizontalBlur:send('amount', selected and .006 or .003)
  data.media.shaders.verticalBlur:send('amount', selected and .006 or .003)
  g.setColor(255, 255, 255)
  for i = 1, 3 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.backCanvas:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.draw(self.backCanvas)
    end)
  end

  g.setShader()
  g.setColor(255, 255, 255)
  g.draw(self.canvas, lerpd.x, lerpd.y, 0, 1, 1, 100, 100)
  self.animation:draw(lerpd.x, lerpd.y, {noupdate = true})
end

function UnitClient:lerp()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  return table.interpolate(prev, cur, tickDelta / tickRate)
end

function UnitClient:getHealthbar()
  local lerpd = self:lerp()
  if lerpd.dying then lerpd.health = 0 end
  return lerpd.x, ctx.map.height - ctx.map.groundHeight - 80, lerpd.health / lerpd.maxHealth, lerpd.health / lerpd.maxHealth
end
