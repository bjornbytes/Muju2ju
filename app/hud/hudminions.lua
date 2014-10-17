HudMinions = class()

local g = love.graphics

function HudMinions:update()
  local p = ctx.players:get(ctx.id)

	for i = 1, self.count do
		self.factor[i] = math.lerp(self.factor[i], p.selectedMinion == i and 1 or 0, 10 * tickRate)
		self.extra[i] = math.lerp(self.extra[i], 0, 5 * tickRate)
		if p.minions[i] then
			local y = self.bg[i]:getHeight() * (p.minioncds[i] / 3)
			self.quad[i]:setViewport(0, y, self.bg[i]:getWidth(), self.bg[i]:getHeight() - y)
		end
	end
end

function HudMinions:draw()
  if ctx.net.state == 'ending' then return end

  local p = ctx.players:get(ctx.id)
  if not p then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local ct = table.count(p.deck)

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
  local inc = u * (.1 + (.15 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)
  local font = ctx.hud.boldFont

  g.setColor(0, 0, 0, 65 * math.clamp(upgradeFactor, 0, 1))
  g.rectangle('fill', 0, 0, ctx.view.frame.width, ctx.view.frame.height)

  for i = 1, self.count do
    local bg = self.bg[i]
    local w, h = bg:getDimensions()
    local scale = (.1 + (.0175 * self.factor[i]) + (.012 * self.extra[i]) + (.02 * upgradeFactor)) * v / w
    local yy = v * (.07 + (.07 * upgradeFactor))
    local f, cost = font, tostring('12')
    --local tx, ty = xx - w / 2 - f:getWidth(cost) / 2 - (w * .75 / 2) + 4, yy - f:getHeight() / 2 - (h * .75 / 2) + 4
    local alpha = .65 + self.factor[i] * .35

    -- Backdrop
    g.setColor(255, 255, 255, 80 * alpha)
    g.draw(bg, xx, yy, 0, scale, scale, w / 2, h / 2)

    -- Cooldown
    local _, qy = self.quad[i]:getViewport()
    g.setColor(255, 255, 255, (150 + (100 * (p.minioncds[i] == 0 and 1 or 0))) * alpha)
    g.draw(bg, self.quad[i], xx, yy + qy * scale, 0, scale, scale, w / 2, h / 2)

    -- Juice
    g.setBlendMode('additive')
    g.setColor(255, 255, 255, 60 * self.extra[i])
    g.draw(bg, xx, yy, 0, scale + .2 * self.extra[i], scale + .2 * self.extra[i], w / 2, h / 2)
    g.setBlendMode('alpha')

    -- Cost
    --[[g.setFont(ctx.hud.boldFont)
    g.setColor(0, 0, 0, 200 + 55 * self.factor[i])
    g.print(cost, tx + 1, ty + 1)
    g.setColor(255, 255, 255, 200 + 55 * self.factor[i])
    g.print(cost, tx, ty)]]

    do
      local yy = yy + .13 * v
      local inc = .1 * upgradeFactor * v

      g.setColor(0, 0, 0, 160 * upgradeAlphaFactor)
      g.circle('fill', xx - inc, yy, .04 * v)
      g.circle('fill', xx, yy, .04 * v)
      g.circle('fill', xx + inc, yy, .04 * v)
      g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
      g.circle('line', xx - inc, yy, .04 * v)
      g.circle('line', xx, yy, .04 * v)
      g.circle('line', xx + inc, yy, .04 * v)

      --[[inc = .12 * upgradeFactor * v
      yy = yy + .1 * v

      g.setColor(0, 0, 0, 160 * upgradeAlphaFactor)
      g.circle('fill', xx - inc, yy, .05 * v)
      g.circle('fill', xx, yy, .05 * v)
      g.circle('fill', xx + inc, yy, .05 * v)
      g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
      g.circle('line', xx - inc, yy, .05 * v)
      g.circle('line', xx, yy, .05 * v)
      g.circle('line', xx + inc, yy, .05 * v)]]
    end

    xx = xx + inc
  end
end

function HudMinions:ready()
  local p = ctx.players:get(ctx.id)

  self.count = table.count(p.deck)
  self.bg = {}
  self.factor = {}
  self.extra = {}
  self.quad = {}

  for i = 1, self.count do
    self.bg[i] = data.media.graphics.selectZuju
    self.factor[i] = 0
    self.extra[i] = 0

    local w, h = self.bg[i]:getDimensions()
    self.quad[i] = g.newQuad(0, 0, w, h, w, h)
  end
end
