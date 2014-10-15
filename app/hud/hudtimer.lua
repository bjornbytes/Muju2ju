HudTimer = class()

local g = love.graphics

function HudTimer:draw()
  if ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v

  local total = ctx.timer * tickRate
  local seconds = math.floor(total % 60)
  local minutes = math.floor(total / 60)
  if minutes < 10 then minutes = '0' .. minutes end
  if seconds < 10 then seconds = '0' .. seconds end

  local str = minutes .. ':' .. seconds
  g.setColor(255, 255, 255)
  g.setFont('inglobalb', .03 * v)
  g.print(str, u - (.04 * v) - g.getFont():getWidth(str), v * .04)
end

