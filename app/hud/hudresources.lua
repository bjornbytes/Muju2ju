HudResources = class()

local g = love.graphics

function HudResources:draw()
  if ctx.net.state == 'ending' then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)
  local font = g.setFont('mesmerize', .02 * v)
  local x = .8 * u
  local height = font:getHeight() + (.02 * v)
  g.setColor(0, 0, 0, 150)
  g.rectangle('fill', x, -1, .2 * u, height)
  g.setColor(100, 100, 100)
  g.rectangle('line', x + .5, -1 + .5, .2 * u, height)

  g.setColor(255, 255, 255)

  local juju = data.media.graphics.juju
  local scale = (height - 8) / juju:getHeight()
  g.draw(juju, x + 8, height / 2, 0, scale, scale, 0, juju:getHeight() / 2)
  g.setColor(150, 255, 100)
  g.print(math.floor(p.juju), x + 8 + juju:getWidth() * scale + 4, height / 2 - font:getHeight() / 2)

  local population = p:getPopulation()
  if population >= p.maxPopulation then g.setColor(255, 150, 100)
  else g.setColor(255, 255, 255) end

  str = population .. ' / ' .. p.maxPopulation
  x = x + .1 * u - font:getWidth(str) / 2
  g.print(str, x, height / 2 - font:getHeight() / 2)

  local total = ctx.timer * tickRate
  local seconds = math.floor(total % 60)
  local minutes = math.floor(total / 60)
  if minutes < 10 then minutes = '0' .. minutes end
  if seconds < 10 then seconds = '0' .. seconds end

  local str = minutes .. ':' .. seconds
  g.setColor(255, 255, 255)
  g.print(str, u - font:getWidth(str) - 8, height / 2 - font:getHeight() / 2)

  --[[if table.has(arg, 'test') then
    g.setFont('pixel', 8)
    local str = love.timer.getFPS()
    if ctx.net.server:round_trip_time() then
      str = str .. '\n' .. ctx.net.server:round_trip_time() .. 'ms'
    end
    g.print(str, u - g.getFont():getWidth(str) - 2, 2)
  end]]
end

