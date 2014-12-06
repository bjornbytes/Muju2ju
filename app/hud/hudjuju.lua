HudJuju = class()

local g = love.graphics

function HudJuju:init()
  self.scale = .1
end

function HudJuju:update()
  self.scale = math.lerp(self.scale, .1, 12 * tickRate)
end

function HudJuju:draw()
  if ctx.net.state == 'ending' then return end

  local p = ctx.players:get(ctx.id)
  if not p then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local image = data.media.graphics.juju
  local upgradeFactor = ctx.hud.upgrades:getFactor()
  local scale = self.scale * ctx.hud.v / image:getWidth()

  g.setFont('inglobalb', .022 * v)
  local font = g.getFont()

  local corner = .9 * u
  local top = .02 * v

  g.setColor(255, 255, 255, 255 * 1)
  g.draw(image, corner, top, 0, scale, scale)
  g.setColor(0, 0, 0)

  local x, y = corner + (image:getWidth() * scale) / 2, top + (image:getHeight() * scale) / 2
  local str = tostring(math.floor(p.juju))
  g.print(str, x - font:getWidth(str) / 2, y - font:getHeight() / 2)
  g.setColor(255, 255, 255)
end
