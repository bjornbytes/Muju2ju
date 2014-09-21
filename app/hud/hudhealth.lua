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

  local px, py = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate)
  local green = {50, 230, 50}
  local red = {255, 0, 0}
  local purple = {200, 80, 255}

  bar(px - 40, py - 15, ctx.player.healthDisplay / ctx.player.maxHealth, purple, 80, 3)
  bar(ctx.shrine.x - 60, ctx.shrine.y - 65, ctx.shrine.healthDisplay / ctx.shrine.maxHealth, green, 120, 4)

  local t = {}
  ctx.enemies:each(function(enemy)
    local location = math.floor(enemy.x)
    stack(t, location, enemy.width * 2, .5)
    bar(enemy.x - 25, ctx.map.height - ctx.map.groundHeight - enemy.height - 15 - 15 * t[location], enemy.healthDisplay / enemy.maxHealth, red, 50, 2)
  end)

  t = {}
  ctx.minions:each(function(minion)
    local location = math.floor(minion.x)
    stack(t, math.floor(minion.x), minion.width * 2, .5)
    bar(minion.x - 25, ctx.map.height - ctx.map.groundHeight - minion.height - 15 * t[location], minion.healthDisplay / minion.maxHealth, green, 50, 2)
  end)
end
