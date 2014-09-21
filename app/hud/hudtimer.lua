HudTimer = class()

local g = love.graphics

function HudTimer:draw()
  if ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local font = ctx.hud.boldFont

  local total = ctx.timer * tickRate
  local seconds = math.floor(total % 60)
  local minutes = math.floor(total / 60)
  if minutes < 10 then minutes = '0' .. minutes end
  if seconds < 10 then seconds = '0' .. seconds end

  local str = minutes .. ':' .. seconds
  g.setColor(255, 255, 255)
  g.setFont(font)
  g.print(str, ctx.view.frame.width - 25 - font:getWidth(str), 25)
end

