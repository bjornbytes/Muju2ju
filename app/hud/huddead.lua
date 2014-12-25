HudDead = class()

local g = love.graphics

function HudDead:init()
  self.splashAlpha = 0
  self.prevSplashAlpha = self.splashAlpha

  self.rewardAlpha = 0
  self.prevRewardAlpha = self.rewardAlpha

  self.continueHover = false

  ctx.event:on('rewards', function(data)
    self.rewards = data
  end)
end

function HudDead:update()
  if ctx.net.state ~= 'ending' then return end

  self.prevSplashAlpha, self.prevRewardAlpha = self.splashAlpha, self.rewardAlpha

  self.splashAlpha = math.lerp(self.splashAlpha, 1, 3 * tickRate)

  if self.splashAlpha > .9 then
    self.rewardAlpha = math.lerp(self.rewardAlpha, 1, 5 * tickRate)
  end

  if self.rewards then
    local u, v = ctx.hud.u, ctx.hud.v
    local ct = table.count(self.rewards.runes) + table.count(self.rewards.units)
    local i = 1
    local size = .1 * v
    local inc = size + (.05 * v)
    local xx = u * .5 - (inc * (ct - 1) / 2)
    local yy = .58 * v
    local mx, my = love.mouse.getPosition()

    table.each(self.rewards.runes, function(rune)
      if math.distance(mx, my, xx, yy) < size / 2 then
        ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:runeTooltip(rune.id))
      end

      i = i + 1
      xx = xx + inc
    end)

    table.each(self.rewards.units, function(unit)
      if math.distance(mx, my, xx, yy) < size / 2 then
        ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:unitTooltip(unit))
      end

      i = i + 1
      xx = xx + inc
    end)
  end
end

function HudDead:draw()
  if ctx.net.state ~= 'ending' then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)

  local splashAlpha = math.lerp(self.prevSplashAlpha, self.splashAlpha, tickDelta / tickRate)
  local rewardAlpha = math.lerp(self.prevRewardAlpha, self.rewardAlpha, tickDelta / tickRate)

  g.setColor(255, 255, 255, 255 * splashAlpha)
  local img = data.media.graphics[ctx.winner == p.team and 'victory' or 'defeat']
  local scale = .55 * v / img:getHeight()
  g.draw(img, .5 * u, 0, 0, scale, scale, img:getWidth() / 2, 0)

  g.setColor(255, 255, 255, 255 * rewardAlpha)

  local img = data.media.graphics.newitems
  local scale = .35 * u / img:getHeight()
  g.draw(img, u * .5, .55 * v, 0, scale, scale, img:getWidth() / 2, img:getHeight() / 2)

  local font = g.setFont('pixel', 8)
  local str = 'New Items!'
  g.print(str, u * .5 - font:getWidth(str) / 2, .5 * v - font:getHeight() / 2)

  if self.rewards then
    local ct = table.count(self.rewards.runes) + table.count(self.rewards.units)
    local i = 1
    local size = .1 * v
    local inc = size + (.05 * v)
    local xx = u * .5 - (inc * (ct - 1) / 2)
    local yy = .58 * v
    local mx, my = love.mouse.getPosition()

    table.each(self.rewards.runes, function(rune)
      g.circle('line', xx, yy, size / 2)
      i = i + 1
      xx = xx + inc
    end)

    table.each(self.rewards.units, function(unit)
      g.circle('line', xx, yy, size / 2)
      i = i + 1
      xx = xx + inc
    end)
  end
    
  -- Continue Button
  local img = data.media.graphics.continue
  local scale = .1 * v / img:getHeight()
  local x, y = self:continueGeometry()
  g.draw(img, x, y, 0, scale, scale)
end

function HudDead:mousereleased(mx, my, b)
  if ctx.net.state ~= 'ending' then return end

  if b == 'l' then
    local x, y, w, h = self:continueGeometry()
    if math.inside(mx, my, x, y, w, h) then
      Context:remove(ctx)
      Context:add(Menu, self.user)
    end
  end
end

function HudDead:continueGeometry()
  local u, v = ctx.hud.u, ctx.hud.v
  local img = data.media.graphics.continue
  local scale = .1 * v / img:getHeight()
  return .5 * u - img:getWidth() * scale / 2, .9 * v - img:getHeight() * scale / 2, img:getDimensions()
end
