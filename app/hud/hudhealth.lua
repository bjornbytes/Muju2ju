HudHealth = class()

local g = love.graphics

local function bar(x, y, percent, color, width, thickness)
	thickness = thickness or 2
  x, y = ctx.view:screenPoint(x, y)

	g.setColor(0, 0, 0, 160)
	g.rectangle('fill', x, y, width + 1, thickness + 1)
	g.setColor(color)
	g.rectangle('fill', x, y, percent * width, thickness)
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

  ctx.players:each(function(player)
    local x, y, amt = player:getHealthbar()
    local color = (p and player.team == p.team) and green or red
    bar(x - 40, y - 15, amt, color, 80, 3)
  end)

  ctx.shrines:each(function(shrine)
    local color = (p and shrine.team == p.team) and green or red
    bar(shrine.x - 60, shrine.y - 65, shrine.healthDisplay / shrine.maxHealth, color, 120, 4)
  end)

  local t = {}
  ctx.units:each(function(unit)
    local location = math.floor(unit.x)
    stack(t, location, unit.width * 2, .5)
    local color = green
    local color = (p and unit.team == p.team) and green or red
    local x, y, amt = unit:getHealthbar()
    bar(x - 25, y - 15 * t[location], amt, color, 50, 2)
  end)
end
