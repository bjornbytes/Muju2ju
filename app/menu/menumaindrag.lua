MenuMainDrag = class()

local g = love.graphics

function MenuMainDrag:init()
  self:resetDrag()
end

function MenuMainDrag:update()
  if self.active then
    --
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
    if math.inside(mx, my, gx, gy, gutter.width * u, gutter.frameHeight) then
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
        local units = deck.geometry.units
        for i = 1, #units do
          local x, y, r = unpack(units[i])
          x, y = deck:screenPoint(x, y)
          if math.insideCircle(mx, my, x, y, r) then
            local unit = ctx.user.deck[i]
            
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
        end
      end
    end
    
    self:resetDrag()
  elseif b == 'r' and not self.active then
    local deck, gutter = ctx.pages.main.deck, ctx.pages.main.gutter
    local units = deck.geometry.units
    for i = 1, #units do
      local x, y, r = unpack(units[i])
      x, y = deck:screenPoint(x, y)
      if math.insideCircle(mx, my, x, y, r) then
        local unit = ctx.user.deck[i]
        if unit then
          while #unit.runes > 0 do
            table.insert(gutter.runes, table.remove(unit.runes, 1))
          end

          table.insert(gutter.units, unit.code)
          ctx.user.deck[i] = nil

          table.clear(gutter.geometry)
        end
      end
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
