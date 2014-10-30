HudHealth = class()

local g = love.graphics

local function bar(x, y, hard, soft, color, width, height)
	thickness = thickness or 2
  x, y = ctx.view:screenPoint(x, y)
  width = width * ctx.view.scale

  g.setColor(255, 255, 255)
  local w, h = data.media.graphics.healthbarFrame:getDimensions()
  local scale = width / w
  local xx = math.round(x - width / 2)
  local yy = math.round(y)

  g.draw(data.media.graphics.healthbarFrame, xx, yy, 0, scale, scale)

  local tiny = math.round(3 * scale) == 0
  yy = yy + (tiny and 1 or math.round(3 * scale))
  xx = xx + (tiny and 1 or math.round(3 * scale))

  local barHeight = data.media.graphics.healthbarGradient:getHeight()
	g.setColor(color[1], color[2], color[3], 100)
  g.rectangle('fill', xx, yy, hard * math.round(width - 6 * scale) - (tiny and 1 or 0), math.round((h - 6) * scale) - (tiny and 1 or 0))
  g.setBlendMode('additive')
	g.setColor(255, 255, 255, 180)
	g.draw(data.media.graphics.healthbarGradient, xx, yy, 0, 1 * math.round(width - 6 * scale), scale)
  g.setBlendMode('alpha')
end

local function stack(t, x, range, delta)
	for i = x - range, x + range, 1 do
    t[i] = t[i] and (t[i] + delta) or 1
	end
end

function HudHealth:draw()
  if ctx.net.state == 'ending' then return end

  local green = {50, 230, 50}
  local red = {255, 0, 0}
  local purple = {200, 80, 255}

  local p = ctx.players:get(ctx.id)
  local vx, vy = math.lerp(ctx.view.prevx, ctx.view.x, tickDelta / tickRate), math.lerp(ctx.view.prevy, ctx.view.y, tickDelta / tickRate)

  ctx.players:each(function(player)
    local color = (p and player.team == p.team) and green or red
    local x, y, hard, soft = player:getHealthbar()
    bar(x, y - 15, hard, soft, color, 80, 3)
  end)

  ctx.shrines:each(function(shrine)
    local color = (p and shrine.team == p.team) and green or red
    local x, y, hard, soft = shrine:getHealthbar()
    local w, h = 120 + (60 * (shrine.hurtFactor)), 4 + (1 * shrine.hurtFactor)
    bar(x, y - 65, hard, soft, color, w, h)
  end)

  local t = {}
  ctx.units:each(function(unit)
    local location = math.floor(unit.x)
    stack(t, location, unit.width * 2, 1)
    local color = green
    local color = (p and unit.team == p.team) and green or red
    local x, y, hard, soft = unit:getHealthbar()
    bar(x, y - 5 * t[location], hard, soft, color, 50, 2)
  end)
end
