MenuMainGutter = class()

local g = love.graphics

function MenuMainGutter:init()
  self.active = true
  self.width = .25
  self.offset = 0
  self.targetScroll = 0
  self.scroll = self.targetScroll
  self.lepr = Lepr(self, .4, 'inOutQuart', {'offset'})
end

function MenuMainGutter:update()
  local u, v = ctx.u, ctx.v
  self.frameHeight = v - (ctx.nav.height * v + .5)
  self.height = v - (ctx.nav.height * v + .5)
  self.height = self.height * 1.1
  if self.targetScroll < 0 then self.targetScroll = math.lerp(self.targetScroll, 0, 12 * tickRate)
  elseif self.targetScroll > self.height - self.frameHeight then self.targetScroll = math.lerp(self.targetScroll, self.height - self.frameHeight, 12 * tickRate) end
end

function MenuMainGutter:draw()
  local u, v = ctx.u, ctx.v

  self.lepr:update(delta)
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * delta)

  local x = self.offset
  local y = ctx.nav.height * v + .5
  g.setColor(255, 255, 255)
  g.line((x + self.width) * u - .5, y, (x + self.width) * u - .5, v)

  g.setScissor(x * u, y, self.width * u, self.frameHeight)
  g.push()
  g.translate(0, -self.scroll)

  -- Draw all your stuff in screen coordinates, not worrying about if stuff is drawn off screen.
  local yy = y + .02 * u
  local xx = (self.offset + .02) * u
  g.setFont('inglobalb', .04 * v)
  local font = g.getFont()
  g.print('Minions', xx, yy)
  yy = yy + font:getHeight() + .02 * v

  g.print('Runes', xx, yy)

  g.pop()
  g.setScissor()
  
  g.setColor(255, 255, 255, 100)
  local percent = self.scroll / ((self.height == self.frameHeight) and 1 or (self.height - self.frameHeight))
  local height = self.frameHeight / self.height * self.frameHeight
  local scrolly = y + (percent * (self.frameHeight - height))
  local clamped = math.clamp(scrolly, y, y + self.frameHeight - height)
  local dif = math.abs(scrolly - clamped)
  if clamped > scrolly then
    height = height - dif
  elseif clamped < scrolly then
    clamped = clamped + dif
    height = height - dif
  end
  g.rectangle('fill', (x + self.width) * u - 6, clamped, 4, height)

  g.setColor(255, 255, 255)
end

function MenuMainGutter:keypressed(key)
  if key == ' ' then
    self.active = not self.active
    if self.active then
      self.offset = 0
    else
      self.offset = -.25
    end
    self.lepr:reset()
  end
end

function MenuMainGutter:mousepressed(x, y, b)
  local u, v = ctx.u, ctx.v
  if math.inside(x, y, self.offset * u, ctx.nav.height * v, self.width * u, self.frameHeight) then
    if b == 'wd' then
      self.targetScroll = self.targetScroll + 32
    elseif b == 'wu' then
      self.targetScroll = self.targetScroll - 32
    end
  end
end

