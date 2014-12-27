MenuError = class()

local g = love.graphics

function MenuError:init()
  self.alpha = 0
  self.prevalpha = 0

  self.height = .09
  self.fontSize = .03

  self.text = ''
end

function MenuError:update()
  self.prevalpha = self.alpha

  if self.alpha > 0 then self.alpha = self.alpha - math.min(tickRate, self.alpha) end
end

function MenuError:draw()
  if self.alpha == 0 then return end

  local u, v = ctx.u, ctx.v
  local alpha = math.clamp(math.lerp(self.prevalpha, self.alpha, tickDelta / tickRate), 0, 1) * 255
  local font = g.setFont('mesmerize', self.fontSize * v)
  local padding = (self.height - self.fontSize) / 2 * v
  local width = padding + (self.fontSize * v) + padding + font:getWidth(self.text) + padding

  g.setColor(0, 0, 0, math.max(alpha - 50, 0))
  local x = u * .5 - width / 2
  local y = v * .5 - self.height * v / 2
  g.rectangle('fill', x, y, width, self.height * v)
  g.setColor(80, 80, 80, alpha)
  g.rectangle('line', math.round(x) + .5, math.round(y) + .5, width, self.height * v)

  local image = data.media.graphics.spujuSkull
  local w, h = image:getDimensions()
  local scale = (self.fontSize * v) / w
  local x = x + padding + (w * scale / 2)
  g.setColor(255, 255, 255, alpha)
  g.draw(image, x, y + (self.height * v / 2), angle, s, s, w / 2, h / 2)

  g.setColor(255, 100, 100, alpha)
  g.print(self.text, x + (w * scale / 2) + padding, y + (self.height * v / 2) - font:getHeight() / 2 - 1)
end

function MenuError:set(text)
  self.text = text
  self.alpha = 2
end
