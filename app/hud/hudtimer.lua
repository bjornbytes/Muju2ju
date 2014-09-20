HudTimer = class()

local g = love.graphics

function HudTimer:init()
	self.values = {total = 0, minutes = 0, seconds = 0}
end

function HudTimer:update()
	if not ctx.hud.upgrades.active and not ctx.paused and not ctx.ded then
		self.values.total = self.values.total + 1
	end
end

function HudTimer:draw()
  if ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local font = ctx.hud.boldFont

  local total = self.values.total * tickRate
  self.values.seconds = math.floor(total % 60)
  self.values.minutes = math.floor(total / 60)
  if self.values.minutes < 10 then
    self.values.minutes = '0' .. self.values.minutes
  end
  if self.values.seconds < 10 then
    self.values.seconds = '0' .. self.values.seconds
  end

  local str = self.values.minutes .. ':' .. self.values.seconds
  g.setColor(255, 255, 255)
  g.setFont(font)
  g.print(str, ctx.view.frame.width - 25 - font:getWidth(str), 25)
end

