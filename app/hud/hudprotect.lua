HudProtect = class()

local g = love.graphics

function HudProtect:init()
  self.font = g.newFont('media/fonts/inglobal.ttf', 64)
	self.alpha = 3
end

function HudProtect:update()
	self.alpha = timer.rot(self.alpha)
end

function HudProtect:draw()
  if ctx.ded then return end
end
