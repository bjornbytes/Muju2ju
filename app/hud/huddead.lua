HudDead = class()

local g = love.graphics

function HudDead:init()
  self.splashAlpha = 0
  self.prevSplashAlpha = self.splashAlpha

  self.rewardAlpha = 0
  self.prevRewardAlpha = self.rewardAlpha
end

function HudDead:update()
  if ctx.net.state ~= 'ending' then return end

  self.prevSplashAlpha, self.prevRewardAlpha = self.splashAlpha, self.rewardAlpha

  self.splashAlpha = math.lerp(self.splashAlpha, 1, 3 * tickRate)

  if self.splashAlpha > .9 then
    self.rewardAlpha = math.lerp(self.rewardAlpha, 1, 5 * tickRate)
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
    
  -- Continue Button
  local img = data.media.graphics.continue
  local scale = .1 * v / img:getHeight()
  g.draw(img, .5 * u, .9 * v, 0, scale, scale, img:getWidth() / 2, img:getHeight() / 2)
end

function HudDead:mousereleased(x, y, b)
  local u, v = ctx.hud.u, ctx.hud.v
  if b == 'l' then
    local img = data.media.graphics.continue
    local scale = .1 * v / img:getHeight()
    if math.inside(x, y, .5 * u - img:getWidth() * scale / 2, .9 * v - img:getHeight() * scale / 2, img:getDimensions()) then
      Context:remove(ctx)
      Context:add(Menu, self.user)
    end
  end
end

