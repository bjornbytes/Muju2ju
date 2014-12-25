HudMinions = class()

local g = love.graphics

function HudMinions:init()
  self.spread1 = 0
  self.spread2 = 0

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    upgrades = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local p = ctx.players:get(ctx.id)
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
      local minionInc = u * (.1 + (.18 * upgradeFactor))
      local inc = .1 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local yy = v * (.07 + (.07 * upgradeFactor)) + (.11 * v)
      local radius = math.max(.035 * v * upgradeFactor, .01)
      local spreadFactor = 3.5 - (self.spread1 + self.spread2) ^ .75
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        for j = 1, 2 do
          local sign = j == 1 and -1 or 1
          local xx = xx + (inc / 2 + inc * self['spread' .. j] / spreadFactor) * sign
          res[i][j] = {xx, yy, radius, {}}

          if p.deck[i].upgrades[j] then
            for k = 1, 2 do
              local yy = yy + (.08 * v)
              local sign = k == 1 and -1 or 1
              local xx = xx + (inc / 2) * sign
              res[i][j][4][k] = {xx, yy, radius}
            end
          end
        end

        xx = xx + minionInc
      end

      return res
    end,

    runes = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
      local minionInc = u * (.1 + (.18 * upgradeFactor))
      local inc = .1 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local yy = v * (.07 + (.07 * upgradeFactor)) + (.11 * v)
      local radius = math.max(.035 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        local yy = yy + (.08 * v) + (.02 * v) + (.1 * v) * math.max(self.spread1, self.spread2)
        res[i] = {}

        for j = 1, 3 do
          local sign = j - 2
          res[i][j] = {xx + inc * sign, yy, radius}
        end

        xx = xx + minionInc
      end

      return res
    end
  }
end

function HudMinions:update()
  local p = ctx.players:get(ctx.id)

	for i = 1, self.count do
		self.factor[i] = math.lerp(self.factor[i], p.selected == i and 1 or 0, 10 * tickRate)
	end

  local mx, my = love.mouse.getPosition()
  local runes = self.geometry.runes
  for minion = 1, #runes do
    for i = 1, #runes[minion] do
      if math.insideCircle(mx, my, unpack(runes[minion][i])) and p.deck[minion].runes[i] then
        ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:runeTooltip(p.deck[minion].runes[i].id))
      end
    end
  end

  local upgrades = self.geometry.upgrades
  for minion = 1, #upgrades do
    for upgrade = 1, #upgrades[minion] do
      local x, y, r, children = unpack(upgrades[minion][upgrade])
      if math.insideCircle(mx, my, x, y, r) then
        ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:abilityTooltip(p.deck[minion].code, upgrade))
      else
        for i = 1, #children do
          if math.insideCircle(mx, my, unpack(children[i])) then
            ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:abilityUpgradeTooltip(p.deck[minion].code, upgrade, i))
          end
        end
      end
    end
  end
end

function HudMinions:draw()
  if ctx.net.state == 'ending' then return end

  local p = ctx.players:get(ctx.id)
  if not p then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local ct = self.count

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
  local inc = u * (.1 + (.18 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)
  local font = ctx.hud.boldFont

  if t < 1 then table.clear(self.geometry) end

  g.setColor(0, 0, 0, 65 * math.clamp(upgradeFactor, 0, 1))
  g.rectangle('fill', 0, 0, ctx.view.frame.width, ctx.view.frame.height)

  for i = 1, self.count do
    local bg = self.bg[i]
    local w, h = bg:getDimensions()
    local scale = (.1 + (.0175 * self.factor[i]) + (.02 * upgradeFactor)) * v / w
    local yy = v * (.07 + (.07 * upgradeFactor))
    local f, cost = font, tostring('12')
    local alpha = .75 + self.factor[i] * .25

    -- Backdrop
    local val = 255 * alpha
    g.setColor(val, val, val, val)
    g.draw(bg, xx, yy, 0, scale, scale, w / 2, h / 2)

    local population = p:getPopulation()
    local str = population .. ' / ' .. p.maxPopulation
    g.setFont('inglobalb', .03 * v)
    g.setColor(0, 0, 0, 200)
    g.print(str, u * .1 + 1, 2 + 1)
    g.setColor(population == p.maxPopulation and {255, 0, 0} or {255, 255, 255}, 255)
    g.print(str, u * .1, 2)

    xx = xx + inc
  end

  local upgrades = self.geometry.upgrades
  for minion = 1, #upgrades do
    for upgrade = 1, 2 do
      local x, y, r, children = unpack(upgrades[minion][upgrade])
      g.setColor(0, 0, 0, 160 * upgradeAlphaFactor)
      g.circle('fill', x, y, r)
      g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
      g.circle('line', x, y, r)

      for i = 1, #children do
        local x, y, r = unpack(children[i])
        g.setColor(0, 0, 0, 160 * upgradeAlphaFactor * self['spread' .. upgrade])
        g.circle('fill', x, y, r)
        g.setColor(255, 255, 255, 255 * upgradeAlphaFactor * self['spread' .. upgrade])
        g.circle('line', x, y, r)
      end
    end
  end

  local runes = self.geometry.runes
  for minion = 1, #runes do
    for i = 1, #runes[minion] do
      local x, y, r = unpack(runes[minion][i])
      g.setColor(0, 0, 0, 200 * upgradeAlphaFactor)
      g.circle('fill', x, y, r)
      if p.deck[minion].runes[i] then
        g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
        g.circle('line', x, y, r)
      end
    end
  end
end

function HudMinions:ready()
  local p = ctx.players:get(ctx.id)

  self.count = #p.deck
  self.bg = {}
  self.factor = {}

  for i = 1, self.count do
    self.bg[i] = data.media.graphics.unit.portrait[p.deck[i].code] or data.media.graphics.menuCove
    self.factor[i] = 0
  end
end
