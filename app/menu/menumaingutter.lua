MenuMainGutter = class()

local g = love.graphics

function MenuMainGutter:init()
  self.active = true
  self.width = .25
  self.offset = 0
  self.targetScroll = 0
  self.scroll = self.targetScroll
  self.height = love.graphics.getHeight() * 2.2
  self.lepr = Lepr(self, .4, 'inOutQuart', {'offset'})
end

function MenuMainGutter:draw()
  local u, v = ctx.u, ctx.v

  self.lepr:update(delta)
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * delta)

  local x = self.offset
  local y = ctx.nav.height * v + .5
  g.setColor(255, 255, 255)
  g.line((x + self.width) * u - .5, y, (x + self.width) * u - .5, v)

  g.setScissor(x * u, y, self.width * u, v - y)
  g.push()
  g.translate(0, -self.scroll)

  -- Draw all your stuff in screen coordinates, not worrying about if stuff is drawn off screen.

  g.pop()
  g.setScissor()
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
  elseif key == 'up' then
    self.targetScroll = self.targetScroll - 8
    self:contain()
  elseif key == 'down' then
    self.targetScroll = self.targetScroll + 8
    self:contain()
  end
end

function MenuMainGutter:mousepressed(x, y, b)
  if b == 'wd' then
    self.targetScroll = self.targetScroll + 32
    self:contain()
  elseif b == 'wu' then
    self.targetScroll = self.targetScroll - 32
    self:contain()
  end
end

function MenuMainGutter:contain()
  local frameHeight = ctx.v - (ctx.nav.height * ctx.v + .5)
  self.targetScroll = math.clamp(self.targetScroll, 0, self.height - frameHeight)
end
