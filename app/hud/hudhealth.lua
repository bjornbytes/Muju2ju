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

  ctx.players:each(function(player)
    local x, y, amt = player:getHealthbar()
    bar(x - 40, y - 15, amt, purple, 80, 3)
  end)

  bar(ctx.shrine.x - 60, ctx.shrine.y - 65, ctx.shrine.healthDisplay / ctx.shrine.maxHealth, green, 120, 4)

  local t = {}
  ctx.units:each(function(unit)
    local location = math.floor(unit.x)
    stack(t, location, unit.width * 2, .5)
    local color = green
    -- if enemy.team ~= p.team then color = red end
    bar(unit.x - 25, ctx.map.height - ctx.map.groundHeight - unit.height - 15 - 15 * t[location], unit.healthDisplay / unit.maxHealth, color, 50, 2)
  end)
end
