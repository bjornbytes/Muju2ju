HudHealth = class()

local g = love.graphics

local function bar(x, y, hard, soft, color, width, height)
	thickness = thickness or 2
  x, y = ctx.view:screenPoint(x, y)
  width = width * ctx.view.scale

  g.setColor(255, 255, 255)
  local w, h = data.media.graphics.healthbarFrame:getDimensions()
  local scale = width / w
  g.draw(data.media.graphics.healthbarFrame, x - width / 2, y, 0, scale, scale)

  y = y + (3 * scale)
  width = width - (6 * scale)
  height = (h - 6) * scale

	g.setColor(color)
	g.rectangle('fill', x - width / 2, y, hard * width, height)
	g.setColor(color[1], color[2], color[3], 160)
	g.rectangle('fill', x - width / 2, y, soft * width, height)
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
    stack(t, location, unit.width * 2, .5)
    local color = green
    local color = (p and unit.team == p.team) and green or red
    local x, y, hard, soft = unit:getHealthbar()
    bar(x, y - 15 * t[location], hard, soft, color, 50, 2)
  end)
end
