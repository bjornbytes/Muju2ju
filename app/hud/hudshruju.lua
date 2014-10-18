HudShruju = class()

local g = love.graphics

function HudShruju:init()

end

function HudShruju:update()

end

function HudShruju:draw()
  local u, v = ctx.hud.u, ctx.hud.v

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3 * .33 + .67

  local ct = 3
  local inc = u * (.1 + (.05 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)
  local yy = v * (1.05 - .12 * upgradeFactor)
  local radius = v * (.025 + .025 * upgradeFactor)

  for i = 1, ct do
    g.setColor(0, 0, 0, 160 * upgradeAlphaFactor)
    g.circle('fill', xx, yy, radius)
    g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
    g.circle('line', xx, yy, radius)

    xx = xx + inc
  end
end

