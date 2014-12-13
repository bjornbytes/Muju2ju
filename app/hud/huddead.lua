HudDead = class()

local g = love.graphics

function HudDead:init()
  self.splashAlpha = 0
  self.splashX = 0
  self.splashTimer = 0

  self.rewardAlpha = 0

  self.state = 'splash'
end

function HudDead:update()
  if self.state == 'splash' and math.abs(self.splashX - ctx.hud.u * .5) < 1 then
    self.splashTimer = self.splashTimer + tickRate
  elseif self.state == 'splash' and math.abs(self.splashX - ctx.hud.u * 1) < 1 then
    self.state = 'rewards'
  end
end

function HudDead:draw()
  if ctx.net.state ~= 'ending' then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)

  if self.state == 'splash' then
    if self.splashTimer < 1.5 then
      self.splashAlpha = math.lerp(self.splashAlpha, 1, 10 * delta)
      self.splashX = math.lerp(self.splashX, .5 * u, 10 * delta)
    else
      self.splashAlpha = math.lerp(self.splashAlpha, 0, 10 * delta)
      self.splashX = math.lerp(self.splashX, 1 * u, 10 * delta)
    end

    g.setColor(255, 255, 255, 255 * self.splashAlpha)
    local font = g.setFont('pixel', 8)
    local str = 'You ' .. (ctx.winner == p.team and 'win' or 'lose') .. '!'
    g.print(str, self.splashX - font:getWidth(str) / 2, .5 * v - font:getHeight() / 2)
  elseif self.state == 'rewards' then
    self.rewardAlpha = math.lerp(self.rewardAlpha, 1, 10 * delta)

    g.setColor(255, 255, 255, 255 * self.rewardAlpha)
    local font = g.setFont('pixel', 8)
    local str = 'But you got some rewards:\n[rewards]'
    g.print(str, u * .5 - font:getWidth(str) / 2, .5 * v - font:getHeight() / 2)
    
    -- Continue Button
    local str = 'Continue'
    g.print(str, u * .5 - font:getWidth(str) / 2, .8 * v)
  end
end

function HudDead:mousereleased(x, y, b)
  local u, v = ctx.hud.u, ctx.hud.v
  if b == 'l' then
    local font = g.setFont('pixel', 8)
    local str = 'Continue'
    local w = font:getWidth(str)
    if math.inside(x, y, u * .5 - w / 2, .8 * v, w, font:getHeight()) then
      Context:remove(ctx)
      Context:add(Menu, self.user)
    end
  end
end

