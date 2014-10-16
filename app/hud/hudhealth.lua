HudHealth = class()

local g = love.graphics

local function bar(x, y, hard, soft, color, width, height)
	thickness = thickness or 2
  x, y = ctx.view:screenPoint(x, y)
  width = width * ctx.view.scale

	g.setColor(0, 0, 0, 160)
	g.rectangle('fill', x - width / 2, y, width + 1, height + 1)
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
  if ctx.ded then return end

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
    local x, y = shrine.x, shrine.y
    local amt = shrine.healthDisplay / shrine.maxHealth
    bar(x, y - 65, amt, amt, color, 120, 4)
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
