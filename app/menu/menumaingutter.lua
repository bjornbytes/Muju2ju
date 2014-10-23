MenuMainGutter = class()

local g = love.graphics

function MenuMainGutter:init()
  self.active = true
  self.width = .25
  self.offset = 0
  self.targetScroll = 0
  self.scroll = self.targetScroll
  self.lepr = Lepr(self, .4, 'inOutQuart', {'offset'})
  self.height = 10000

  self.geometry = {
    units = function()
      local u, v = ctx.u, ctx.v
      g.setFont('inglobalb', .04 * v)
      local fh = g.getFont():getHeight()
      local ct = 4
      local radius = .035 * v
      local inc = .01 * u + 2 * radius
      local x = (self.offset + .02) * u
      local xstart = x
      local y = ctx.nav.height * v + .5
      local res = {}
      y = y + (.02 * u) + fh + (.02 * v)
      for i = 1, ct do
        table.insert(res, {x + radius, y + radius, radius})
        x = x + inc
        if x + inc > (self.offset + self.width - .012) * u then
          x = xstart
          if i ~= ct then y = y + inc end
        end
      end
      y = y + inc
      return res, y
    end,

    runes = function()
      local u, v = ctx.u, ctx.v
      g.setFont('inglobalb', .04 * v)
      local fh = g.getFont():getHeight()
      local ct = 21
      local radius = .035 * v
      local inc = .01 * u + 2 * radius
      local x = (self.offset + .02) * u
      local xstart = x
      local _, y = self.geometry.units()
      y = y + .04 * v
      y = y + fh + .02 * v
      local res = {}
      for i = 1, ct do
        table.insert(res, {x + radius, y + radius, radius})
        x = x + inc
        if x + inc > (self.offset + self.width - .012) * u then
          x = xstart
          if i ~= ct then y = y + inc end
        end
      end
      y = y + inc
      return res, y
    end
  }
end

function MenuMainGutter:update()
  local u, v = ctx.u, ctx.v
  self.frameHeight = v - (ctx.nav.height * v + .5)
  if self.targetScroll < 0 then self.targetScroll = math.lerp(self.targetScroll, 0, 12 * tickRate)
  elseif self.targetScroll > self.height - self.frameHeight then self.targetScroll = math.lerp(self.targetScroll, self.height - self.frameHeight, 12 * tickRate) end
end

function MenuMainGutter:draw()
  local u, v = ctx.u, ctx.v

  self.lepr:update(delta)
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * delta)

  local x = self.offset
  local y = ctx.nav.height * v + .5

  g.setColor(0, 0, 0, 80)
  g.rectangle('fill', x * u, y, self.width * u, self.frameHeight)

  g.setColor(255, 255, 255)
  g.line((x + self.width) * u - .5, y, (x + self.width) * u - .5, v)

  -- Gutter contents
  g.setScissor(x * u, y, self.width * u, self.frameHeight)
  g.push()
  g.translate(0, -self.scroll)

  local yy = y + .02 * u
  local xx = (self.offset + .02) * u
  g.setFont('inglobalb', .04 * v)
  local font = g.getFont()

  -- Units
  g.print('Minions', xx, yy)

  local units, yy = self.geometry.units()
  table.each(units, function(unit)
    g.circle('line', unpack(unit))
  end)

  -- Runes
  yy = yy + .04 * v
  g.print('Runes', xx, yy)
  yy = yy + g.getFont():getHeight() + .02 * v
  local runes, yy = self.geometry.runes()
  table.each(runes, function(rune)
    g.circle('line', unpack(rune))
  end)

  self.height = math.max(yy - y, self.frameHeight)

  g.pop()
  g.setScissor()
  
  -- Scrollbar
  g.setColor(255, 255, 255, 100)
  local percent = self.scroll / ((self.height == self.frameHeight) and 1 or (self.height - self.frameHeight))
  local height = self.frameHeight / self.height * (self.frameHeight - 2)
  local scrolly = y + (percent * (self.frameHeight - height))
  local clamped = math.clamp(scrolly, y + 1, y + self.frameHeight - height - 1)
  local dif = math.abs(scrolly - clamped)
  if clamped > scrolly then
    height = height - dif
  elseif clamped < scrolly then
    clamped = clamped + dif
    height = height - dif
  end
  g.rectangle('fill', (x + self.width - .005) * u - 3, clamped, u * .005, height)
end

function MenuMainGutter:keypressed(key)
  if key == ' ' then
    self:toggle()
  end
end

function MenuMainGutter:mousepressed(x, y, b)
  local u, v = ctx.u, ctx.v
  if math.inside(x, y, self.offset * u, ctx.nav.height * v, self.width * u, self.frameHeight) then
    local scrollSpeed = .1
    if b == 'wd' then
      self.targetScroll = self.targetScroll + (v * scrollSpeed)
    elseif b == 'wu' then
      self.targetScroll = self.targetScroll - (v * scrollSpeed)
    end
  end
end

function MenuMainGutter:toggle()
  self.active = not self.active
  if self.active then
    self.offset = 0
  else
    self.offset = -.25
  end
  self.lepr:reset()
end
