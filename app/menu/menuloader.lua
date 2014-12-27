MenuLoader = class()

local g = love.graphics

function MenuLoader:init()
  self.angle = 0
  self.prevangle = 0
  self.offset = 0
  self.prevoffset = 0

  self.height = .06
  self.fontSize = .03

  self.active = false
  self.text = ''
end

function MenuLoader:update()
  self.prevangle = self.angle
  self.prevoffset = self.offset

  local u, v = ctx.u, ctx.v
  self.offset = math.lerp(self.offset, self.active and self.height * v or 0, math.min(20 * tickRate, 1))
  
  if self.offset > 1 then
    self.angle = math.lerp(self.angle, 2 * math.pi, math.min(3 * tickRate, 1))
    if self.angle > 1.9 * math.pi then self.angle = 0 end
  end
end

function MenuLoader:draw()
  if self.offset < 1 then return end

  local u, v = ctx.u, ctx.v
  local offset = math.ceil(math.lerp(self.prevoffset, self.offset, tickDelta / tickRate))
  local angle = math.anglerp(self.prevangle, self.angle, tickDelta / tickRate)
  local font = g.setFont('mesmerize', self.fontSize * v)
  local padding = (self.height - self.fontSize) / 2 * v
  local width = padding + (self.fontSize * v) + padding + font:getWidth(self.text) + padding

  g.setColor(0, 0, 0, 200)
  g.rectangle('fill', u - width, v - offset, width, self.height * v)

  local image = data.media.graphics.juju
  local w, h = image:getDimensions()
  local scale = (self.fontSize * v) / w
  local x = u - width + padding + (w * scale / 2)
  g.setColor(255, 255, 255)
  local s = scale * (.9 + math.cos(tick / 7) ^ 2 / 4)
  g.draw(image, x, v - offset + (self.height * v / 2), angle, s, s, w / 2, h / 2)

  g.print(self.text, x + (w * scale / 2) + padding, v - offset + (self.height * v / 2) - font:getHeight() / 2 - 1)
end

function MenuLoader:set(text)
  self.text = text
  self.active = true
end

function MenuLoader:unset()
  self.active = false
end
