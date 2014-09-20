HudJuju = class()

local g = love.graphics

function HudJuju:init()
  self.font = love.graphics.newFont('media/fonts/inglobalb.ttf', 14)
  self.scale = .75
end

function HudJuju:update()
  self.scale = math.lerp(self.scale, .75, 12 * tickRate)
end

function HudJuju:draw()
  if ctx.ded then return end

  local image = data.media.graphics.juju

  g.setFont(self.font)
  g.setColor(255, 255, 255, 255 * (1 - ctx.hud.upgrades.alpha))
  g.draw(image, 52, 55, 0, self.scale, self.scale, image:getWidth() / 2, image:getHeight() / 2)
  g.setColor(0, 0, 0)
  g.printf(math.floor(ctx.player.juju), 16, 18 + image:getHeight() * .375 - (self.font:getHeight() / 2), image:getWidth() * .75, 'center')
  g.setColor(255, 255, 255)
end
