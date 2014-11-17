MenuMainGutter = class()

local g = love.graphics

function MenuMainGutter:init()
  self.active = true
  self.width = .30
  self.offset = 0
  self.targetScroll = 0
  self.scroll = self.targetScroll
  self.lepr = Lepr(self, .4, 'inOutQuart', {'offset'})
  self.height = 10000

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    all = function()
      local res = {}
      local ct
      local u, v = ctx.u, ctx.v
      g.setFont('philosopher', .04 * v)
      local fh = g.getFont():getHeight()
      local radius = .035 * v
      local inc = .01 * u + 2 * radius
      local x = .02 * u
      local y = 0
      local xstart, ystart = x, y

      -- Unit Label
      y = y + .02 * u
      res.unitLabel = {x, y}

      -- Units
      ct = #self.units
      res.units = {}
      y = y + fh + (.025 * v)
      for i = 1, ct do
        table.insert(res.units, {x + radius, y + radius, radius})
        x = x + inc
        if true or x + inc > (self.width - .012) * u then
          x = xstart
          if i ~= ct then y = y + inc end
        end
      end
      y = y + inc
      x = xstart
      
      -- Rune Label
      y = y + .04 * v
      res.runeLabel = {x, y}

      -- Runes
      res.runes = {}
      y = y + fh + (.025 * v)
      ct = #self.runes
      for i = 1, ct do
        table.insert(res.runes, {x + radius, y + radius, radius})
        x = x + inc
        if true or x + inc > (self.width - .012) * u then
          x = xstart
          if i ~= ct then y = y + inc end
        end
      end
      y = y + inc

      -- Height
      res.height = math.max(y - ystart, self.frameHeight)

      return res
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
  if self.lepr.tween.clock < self.lepr.tween.duration then ctx.pages.main:resize() end
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * delta)
  self.frameHeight = self.frameHeight or 0

  g.push()
  g.translate(self.offset * u - 1, ctx.nav.height * v + 1)

  g.setColor(5, 25, 40, 80)
  g.rectangle('fill', 0, 0, self.width * u, self.frameHeight)

  g.setColor(255, 255, 255)

  -- Gutter contents
  g.setScissor(self.offset * u, ctx.nav.height * v + .5, self.width * u, self.frameHeight)
  g.push()
  g.translate(0, -self.scroll)

  local geometry = self.geometry.all
  g.setFont('philosopher', .04 * v)
  g.print('Minions', unpack(geometry.unitLabel))
  g.print('Runes', unpack(geometry.runeLabel))

  table.each(geometry.units, function(unit, i)
    local x, y, r = unpack(unit)
    g.circle('line', x, y, r)
    g.print(self.units[i]:capitalize(), x + r + .02 * u, y - g.getFont():getHeight() / 2)
  end)

  table.each(geometry.runes, function(rune)
    local x, y, r = unpack(rune)
    g.circle('line', x, y, r)
    g.print('Rune', x + r + .02 * u, y - g.getFont():getHeight() / 2)
  end)

  self.height = geometry.height

  g.pop()
  g.setScissor()
  
  -- Scrollbar
  g.setColor(255, 255, 255, 100)
  local percent = self.scroll / ((self.height == self.frameHeight) and 1 or (self.height - self.frameHeight))
  local height = self.frameHeight / self.height * (self.frameHeight - 1)
  local scrolly = 0 + (percent * (self.frameHeight - height))
  local clamped = math.clamp(scrolly, 1, self.frameHeight - height - 1)
  local dif = math.abs(scrolly - clamped)
  if clamped > scrolly then
    height = height - dif
  elseif clamped < scrolly then
    clamped = clamped + dif
    height = height - dif
  end
  g.rectangle('fill', (self.width - .005) * u - 1, clamped, u * .005, height)

  g.pop()
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

function MenuMainGutter:resize()
  table.clear(self.geometry)
end

function MenuMainGutter:toggle()
  self.active = not self.active
  if self.active then
    self.offset = 0
  else
    self.offset = -self.width
  end
  self.lepr:reset()
end

function MenuMainGutter:screenPoint(x, y)
  local u, v = ctx.u, ctx.v
  return x + self.offset * u - 1, y and y + ctx.nav.height * v + 1 - self.scroll
end
