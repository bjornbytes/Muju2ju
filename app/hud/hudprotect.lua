HudProtect = class()

local g = love.graphics

function HudProtect:init()
	self.alpha = 3
end

function HudProtect:update()
	self.alpha = timer.rot(self.alpha)
end

function HudProtect:draw()
  if ctx.net.state == 'ending' then return end

  local u, v = ctx.hud.u, ctx.hud.v

  if self.alpha > .01 then
    g.setFont('inglobal', .05 * u)
    g.setColor(0, 0, 0, 150 * math.min(self.alpha, 1))
    g.printf('Protect Your Shrine!', 2, v * .25 + 2, u, 'center')
    g.setColor(253, 238, 65, 255 * math.min(self.alpha, 1))
    g.printf('Protect Your Shrine!', 0, v * .25, u, 'center')
  end
end
