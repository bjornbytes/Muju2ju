HudMinions = class()

local g = love.graphics

function HudMinions:init()
	self.bg = {data.media.graphics.selectZuju, data.media.graphics.selectVuju}
	self.factor = {0, 0}
	self.extra = {0, 0}
	self.quad = {}
  for i = 1, 2 do
    local w, h = self.bg[i]:getDimensions()
    self.quad[i] = g.newQuad(0, 0, w, h, w, h)
  end
end

function HudMinions:update()
  local p = ctx.players:get(ctx.id)

	for i = 1, #self.factor do
		self.factor[i] = math.lerp(self.factor[i], p.selectedMinion == i and 1 or 0, 18 * tickRate)
		self.extra[i] = math.lerp(self.extra[i], 0, 5 * tickRate)
		if p.minions[i] then
			local y = self.bg[i]:getHeight() * (p.minioncds[i] / data.unit[p.minions[i]].cooldown)
			self.quad[i]:setViewport(0, y, self.bg[i]:getWidth(), self.bg[i]:getHeight() - y)
		end
	end
end

function HudMinions:draw()
  if ctx.ded then return end

  local p = ctx.players:get(ctx.id)
  if not p then return end

  local yy = 135
  local font = ctx.hud.boldFont

  for i = 1, #p.minions do
    local bg = self.bg[i]
    local w, h = bg:getDimensions()
    local scale = .75 + (.15 * self.factor[i]) + (.1 * self.extra[i])
    local xx = 48 - 10 * (1 - self.factor[i])
    local f, cost = font, tostring(data.unit[p.minions[i]].cost)
    local tx, ty = xx - f:getWidth(cost) / 2 - (w * .75 / 2) + 4, yy - f:getHeight() / 2 - (h * .75 / 2) + 4
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
    g.setFont(ctx.hud.boldFont)
    g.setColor(0, 0, 0, 200 + 55 * self.factor[i])
    g.print(cost, tx + 1, ty + 1)
    g.setColor(255, 255, 255, 200 + 55 * self.factor[i])
    g.print(cost, tx, ty)
    yy = yy + h
  end
end
