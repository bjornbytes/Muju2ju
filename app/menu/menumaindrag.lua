MenuMainDrag = class()

local g = love.graphics

function MenuMainDrag:init()
  self:resetDrag()
end

function MenuMainDrag:update()
  if self.active then
    --
  else
    local _, unit = self.hoverDeckUnit()

    if unit then
      ctx.tooltip:setTooltip(ctx.tooltip:unitTooltip(unit.code))
    end
  end
end

function MenuMainDrag:draw()
  if self.active then
    self.dragX = math.lerp(self.dragX, love.mouse.getX(), 15 * delta)
    self.dragY = math.lerp(self.dragY, love.mouse.getY(), 15 * delta)
    g.circle('fill', self.dragX, self.dragY, .035 * ctx.v)
  end
end

function MenuMainDrag:mousepressed(mx, my, b)
  if b == 'l' then
    self.active = false

    -- Check if the mouse clicked something in the gutter.
    local u, v = ctx.u, ctx.v
    local gutter = ctx.pages.main.gutter
    local gx, gy = gutter:screenPoint(0, 0)
    if math.inside(mx, my, gx, gy + gutter.scroll, gutter.width * u, gutter.frameHeight) then
      local geometry = ctx.pages.main.gutter.geometry.all
      for i = 1, #geometry.units do
        local x, y, r = unpack(geometry.units[i])
        x, y = gutter:screenPoint(x, y)
        if math.insideCircle(mx, my, x, y, r) then
          self.active = true
          self.dragIndex = i
          self.dragType = 'unit'
          self.dragX = mx
          self.dragY = my
          self.dragOffsetX = x - mx
          self.dragOffsetY = y - my
          return
        end
      end

      for i = 1, #geometry.runes do
        local x, y, r = unpack(geometry.runes[i])
        x, y = gutter:screenPoint(x, y)
        if math.insideCircle(mx, my, x, y, r) then
          self.active = true
          self.dragIndex = i
          self.dragType = 'rune'
          self.dragX = mx
          self.dragY = my
          self.dragOffsetX = x - mx
          self.dragOffsetY = y - my
          return
        end
      end
    end
  end
end

function MenuMainDrag:mousereleased(mx, my, b)
  if b == 'l' then
    if self.active then
      local deck, gutter = ctx.pages.main.deck, ctx.pages.main.gutter

      if self.dragType == 'unit' then
        local i, unit = self:hoverDeckUnits()
        if i then
          if unit then
            while #unit.runes > 0 do
              table.insert(gutter.runes, table.remove(unit.runes, 1))
            end
          end

          ctx.user.deck[i] = {
            code = gutter.units[self.dragIndex],
            skin = {},
            runes = {}
          }

          if not unit then
            table.remove(gutter.units, self.dragIndex)
          else
            gutter.units[self.dragIndex] = unit.code
          end

          table.clear(gutter.geometry)
        end
      elseif self.dragType == 'rune' then
        local unit, i, rune = self:hoverDeckUnitRunes()
        if i and ctx.user.deck[unit] then
          local unit = ctx.user.deck[unit]

          unit.runes[i] = gutter.runes[self.dragIndex]

          if not rune then
            table.remove(gutter.runes, self.dragIndex)
          else
            gutter.runes[self.dragIndex] = rune
          end

          table.clear(gutter.geometry)
        end
      end
    end
    
    self:resetDrag()
  elseif b == 'r' and not self.active then
    local deck, gutter = ctx.pages.main.deck, ctx.pages.main.gutter

    local i, unit = self:hoverDeckUnits()
    if unit then
      while #unit.runes > 0 do
        table.insert(gutter.runes, table.remove(unit.runes, 1))
      end

      table.insert(gutter.units, unit.code)
      ctx.user.deck[i] = nil

      table.clear(gutter.geometry)
    end

    local unit, i, rune = self:hoverDeckUnitRunes()
    if rune then
      table.insert(gutter.runes, rune)
      ctx.user.deck[unit].runes[i] = nil

      table.clear(gutter.geometry)
    end
  end
end

function MenuMainDrag:resetDrag()
  self.active = false
  self.dragging = nil
  self.dragType = nil
  self.dragX = nil
  self.dragY = nil
  self.dragOffsetX = nil
  self.dragOffsetY = nil
end

function MenuMainDrag:hoverGutter(kind)
  local mx, my = love.mouse.getPosition()
  local gutter = ctx.pages.main.gutter
  local objects = gutter.geometry.all[kind .. 's']
  for i = 1, #objects do
    local x, y, r = unpack(objects[i])
    x, y = gutter:screenPoint(x, y)
    if math.insideCircle(mx, my, x, y, r) then
      return gutter[kind .. 's'], i
    end
  end
end

function MenuMainDrag:hoverDeckUnits()
  local mx, my = love.mouse.getPosition()
  local deck = ctx.pages.main.deck
  local units = deck.geometry.units
  for i = 1, #units do
    local unit = units[i]
    local x, y, r = unpack(unit)
    x, y = deck:screenPoint(x, y)
    if math.insideCircle(mx, my, x, y, r) then
      return i
    end
  end

  return nil
end

function MenuMainDrag:hoverDeckUnitRunes()
  local mx, my = love.mouse.getPosition()
  local deck = ctx.pages.main.deck
  local unitRunes = deck.geometry.unitRunes
  for i = 1, #unitRunes do
    for j = 1, #unitRunes[i] do
      local rune = unitRunes[i][j]
      local x, y, r = unpack(rune)
      x, y = deck:screenPoint(x, y)
      if math.insideCircle(mx, my, x, y, r) then
        return i, j, ctx.user.deck[i].runes[j]
      end
    end
  end

  return nil
end

function MenuMainDrag:makeUnitTooltip(unit)
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. data.unit[unit.code].name .. '{normal}')
  table.insert(pieces, 'This unit is actually really cool.')
  return table.concat(pieces, '\n')
end

function MenuMainDrag:richOptions()
  local options = {}
  options.title = Typo.font('inglobal', .04 * ctx.v)
  options.normal = Typo.font('inglobal', .023 * ctx.v)
  options.white = {255, 255, 255}
end
