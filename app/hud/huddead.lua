HudDead = class()

local g = love.graphics

function HudDead:init()
  self.alpha = 0
end

function HudDead:update()
  self.alpha = math.lerp(self.alpha, ctx.net.state == 'ending' and 1 or 0, 12 * tickRate)
end

function HudDead:draw()
  if ctx.net.state ~= 'ending' then return end

  local u, v = ctx.hud.u, ctx.hud.v

  --
end

function HudDead:keypressed(key)
  --
end

function HudDead:mousereleased(x, y, b)
  --
end

function HudDead:textinput(char)
  --
end

function Hud:sendScore()
  --
end
