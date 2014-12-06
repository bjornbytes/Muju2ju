require 'app/unit/unit'

local g = love.graphics

UnitClient = extend(Unit)

function UnitClient:activate()
  self.history = NetHistory(self)
  self.createdAt = tick
  self.backCanvas = g.newCanvas(200, 200)
  self.canvas = g.newCanvas(200, 200)

  return Unit.activate(self)
end

function UnitClient:draw()
  local t = tick - (interp / tickRate)
  if t < self.createdAt then return end
  local prev = self.history:get(t, true)
  local cur = self.history:get(t + 1, true)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)

  if not lerpd.animationIndex then return end

  if self.owner.team == ctx.players:get(ctx.id).team then
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

  data.media.shaders.horizontalBlur:send('amount', self.selected and .006 or .003)
  data.media.shaders.verticalBlur:send('amount', self.selected and .006 or .003)
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

  g.setColor(0, 255, 0)
  g.rectangle('line', self.x - self.width / 2, self.y, self.width, self.height)
end

function UnitClient:getHealthbar()
  local t = tick - (interp / tickRate)
  local prev = self.history:get(t)
  local cur = self.history:get(t + 1)
  local lerpd = table.interpolate(prev, cur, tickDelta / tickRate)
  return lerpd.x, ctx.map.height - ctx.map.groundHeight - 80, lerpd.health / lerpd.maxHealth, self.health / lerpd.maxHealth
end
