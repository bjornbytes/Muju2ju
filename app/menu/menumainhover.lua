MenuMainHover = class()

local g = love.graphics

function MenuMainHover:init()
  self:resetDrag()
end

function MenuMainHover:update()
  if self.active then
    print('hello i am dragging a ' .. self.kind)
  end
end

function MenuMainHover:draw()
  if self.active then
    local u, v = ctx.u, ctx.v
    local radius = .035 * v

    self.dragX = math.lerp(self.dragX, love.mouse.getX(), 16 * delta)
    self.dragY = math.lerp(self.dragY, love.mouse.getY(), 16 * delta)

    g.setColor(255, 255, 255)
    g.circle('line', self.dragX + self.dragOffsetX, self.dragY + self.dragOffsetY, radius)
  end
end

function MenuMainHover:mousepressed(mx, my, b)
  if b == 'l' then
    self.active = false

    -- Check if the mouse clicked something in the gutter.
    local units, yy = ctx.pages.main.gutter.geometry.units()
    for i = 1, #units do
      local x, y, r = unpack(units[i])
      if math.insideCircle(mx, my, x, y, r) then
        self.active = true
        self.kind = 'unit'
        self.dragX = mx
        self.dragY = my
        self.dragOffsetX = x - mx
        self.dragOffsetY = y - my
      end
    end

    local runes = ctx.pages.main.gutter.geometry.runes(yy)
    for i = 1, #runes do
      local x, y, r = unpack(runes[i])
      if math.insideCircle(mx, my, x, y, r) then
        self.active = true
        self.kind = 'rune'
        self.dragX = mx
        self.dragY = my
        self.dragOffsetX = x - mx
        self.dragOffsetY = y - my
      end
    end
  end
end

function MenuMainHover:mousereleased(x, y, b)
  if b == 'l' then
    --
    
    self:resetDrag()
  end
end

function MenuMainHover:resetDrag()
  self.active = false
  self.kind = nil
  self.dragX = nil
  self.dragY = nil
  self.dragOffsetX = nil
  self.dragOffsetY = nil
end
