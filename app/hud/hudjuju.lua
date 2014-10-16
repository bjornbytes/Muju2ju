HudJuju = class()

local g = love.graphics

function HudJuju:init()
  self.scale = .1
end

function HudJuju:update()
  self.scale = math.lerp(self.scale, .1, 12 * tickRate)
end

function HudJuju:draw()
  if ctx.ded then return end

  local p = ctx.players:get(ctx.id)
  if not p then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local image = data.media.graphics.juju
  local scale = self.scale * ctx.hud.v / image:getWidth()

  g.setFont('inglobalb', .022 * v)
  local font = g.getFont()

  local corner = .02 * v

  g.setColor(255, 255, 255, 255 * 1)
  g.draw(image, corner, corner, 0, scale, scale)
  g.setColor(0, 0, 0)

  local x, y = corner + (image:getWidth() * scale) / 2, corner + (image:getHeight() * scale) / 2
  local str = tostring(math.floor(p.juju))
  g.print(str, x - font:getWidth(str) / 2, y - font:getHeight() / 2)
  g.setColor(255, 255, 255)
end
