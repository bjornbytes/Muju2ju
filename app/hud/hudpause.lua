HudPause = class()

local g = love.graphics

function HudPause:init()
  self.alpha = 0
end

function HudPause:update()
  self.alpha = math.lerp(self.alpha, ctx.paused and 1 or 0, 12 * tickRate)
end

function HudPause:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local image = media.graphics.pauseMenu

  if self.alpha > .01 then
    g.setColor(0, 0, 0, 128 * self.alpha)
    g.rectangle('fill', 0, 0, g.getDimensions())

    g.setColor(255, 255, 255, 255 * self.alpha)
    g.draw(image, u * .5, v * .5, 0, 1, 1, image:getWidth() / 2, image:getHeight() / 2)
  end
end
