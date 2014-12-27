MenuMainDrag = class()

local g = love.graphics

function MenuMainDrag:init()
  self:resetDrag()
end

function MenuMainDrag:update()
  if self.active then
    --
  else
    local _, unit = self:hoverDeckUnits()
    if unit then
      ctx.tooltip:setTooltip(ctx.tooltip:unitTooltip(unit.code))
    end

    local _, _, rune = self:hoverDeckUnitRunes()
    if rune then
      ctx.tooltip:setTooltip(ctx.tooltip:runeTooltip(rune.id))
    end

    local _, unit = self:hoverGutter('unit')
    if unit then
      ctx.tooltip:setTooltip(ctx.tooltip:unitTooltip(unit))
    end

    local _, rune = self:hoverGutter('rune')
    if rune then
      ctx.tooltip:setTooltip(ctx.tooltip:runeTooltip(rune.id))
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

      for _, kind in pairs({'unit', 'rune'}) do
        local i, obj, x, y = self:hoverGutter(kind)
        if obj then
          self.active = true
          self.dragIndex = i
          self.dragType = kind
          self.dragX = mx
          self.dragY = my
          self.dragOffsetX = x - mx
          self.dragOffsetY = y - my
        end
      end
    end
  end
end

function MenuMainDrag:mousereleased(mx, my, b)
  local deckChanged = false

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

          deckChanged = true
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

          deckChanged = true
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
      deckChanged = true
    end

    local unit, i, rune = self:hoverDeckUnitRunes()
    if rune then
      table.insert(gutter.runes, rune)
      ctx.user.deck[unit].runes[i] = nil
      deckChanged = true
    end
  end

  if deckChanged then
    ctx.hub:send('saveDeck', {deck = ctx.user.deck})
    ctx.loader:set('Saving...')
    table.clear(gutter.geometry)
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
      return i, gutter[kind .. 's'][i], x, y
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
      return i, ctx.user.deck[i]
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
      if math.insideCircle(mx, my, x, y, r) and ctx.user.deck[i] then
        return i, j, ctx.user.deck[i].runes[j]
      end
    end
  end

  return nil
end
