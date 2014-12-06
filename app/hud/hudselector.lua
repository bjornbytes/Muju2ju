HudSelector = class()

local g = love.graphics

function HudSelector:init()
  self.active = false
  self.alpha = 0
  self.x1 = nil
  self.x2 = nil
  self.prevx2 = nil
end

function HudSelector:update()
  if love.mouse.isDown('l') then
    if not self.active then
      self.x1 = love.mouse.getX()
      self.x2 = love.mouse.getX()
    end
    self.active = true
  else
    if self.active then
      self.prevx2 = self.x2

      if self.x1 and self.x2 then
        local p = ctx.players:get(ctx.id)
        table.each(ctx.units.objects, function(unit)
          local x1, x2 = self.x1, self.x2
          if x1 > x2 then x1, x2 = x2, x1 end
          if unit.owner == p then
            unit.selected = false
            local umin, umax = unit.x - unit.width / 2, unit.x + unit.width / 2
            if math.max(x1, umin) <= math.min(x2, umax) then
              unit.selected = true
            end
          end
        end)
      end
      self.active = false
    end
  end

  if self.active then
    self.prevx2 = self.x2
    self.x2 = math.lerp(self.x2, love.mouse.getX(), 12 * tickRate)
  end

  if not self.active or math.abs(self.x1 - self.x2) > 2 then
    self.alpha = math.lerp(self.alpha, self.active and 1 or 0, 5 * tickRate)
  end
end

function HudSelector:draw()
  if not self.x1 or not self.x2 then return end

  local x2 = math.lerp(self.prevx2, self.x2, tickDelta / tickRate)

  local x = math.round(math.min(self.x1, x2)) + .5
  local w = math.round(math.abs(self.x1 - x2))
  
  g.setColor(255, 255, 255, 50 * self.alpha)
  g.rectangle('fill', x, -1, w, ctx.hud.v + 2)

  g.setColor(255, 255, 255, 255 * self.alpha)
  g.rectangle('line', x, -1, w, ctx.hud.v + 2)
end

function HudSelector:mousepressed(x, y, b)
  table.each(ctx.units.objects, function(unit)
    if unit.animation:contains(x, y) then
      unit.selected = true
    end
  end)
end

function HudSelector:mousereleased(x, y, b)
  --
end
