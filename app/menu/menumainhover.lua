MenuMainHover = class()

local g = love.graphics

function MenuMainHover:init()
  self:resetDrag()
end

function MenuMainHover:update()
  if self.active then
    --
  end
end

function MenuMainHover:draw()
  if self.active then
    -- wut
  end
end

function MenuMainHover:mousepressed(mx, my, b)
  if b == 'l' then
    self.active = false

    -- Check if the mouse clicked something in the gutter.
    local geometry = ctx.pages.main.gutter.geometry.all
    for i = 1, #geometry.units do
      local x, y, r = unpack(geometry.units[i])
      if math.insideCircle(mx, my, x, y, r) then
        self.active = true
        self.icon = ctx.pages.main.gutter.units[i]
        self.dragX = mx
        self.dragY = my
        self.dragOffsetX = x - mx
        self.dragOffsetY = y - my
        return
      end
    end

    for i = 1, #geometry.runes do
      local x, y, r = unpack(geometry.runes[i])
      if math.insideCircle(mx, my, x, y, r) then
        self.active = true
        self.icon = ctx.pages.main.gutter.runes[i]
        self.dragX = mx
        self.dragY = my
        self.dragOffsetX = x - mx
        self.dragOffsetY = y - my
        return
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
