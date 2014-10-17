Element = class()

local g = love.graphics

Element.x = 0
Element.y = 0
Element.width = 1
Element.height = 1
Element.padding = {x = 0, y = 0}

function Element:init(data)
  self.event = Event()

  table.merge(data, self, true)
end

function Element:draw()
  local u, v = g.getDimensions()
  local x = self.x > 1 and self.x or self.x * u
  local y = self.y > 1 and self.y or self.y * v
  local w = self.width > 1 and self.width or self.width * u
  local h = self.height > 1 and self.height or self.height * v

  if self.anchor == 'right' then
    x = u - x - w
  end

  if self.background then
    if self.background.typeOf and self.background:typeOf('Drawable') then
      g.setColor(255, 255, 255)
      g.draw(self.background, x, y, 0, w / self.background:getWidth(), h / self.background:getHeight())
    else
      g.setColor(self.background)
      g.rectangle('fill', x, y, w, h)
    end
  end

  if self.border then
    g.setColor(self.border)
    g.rectangle('line', x, y, w, h)
  end
end

function Element:autoFontSize()
  local v = g.getHeight()
  local h = self.height > 1 and self.height or self.height * v
  local padding = type(self.padding) == 'table' and self.padding.y or self.padding
  if padding < 1 then padding = padding * v end
  return h - 2 * padding
end

function Element:mouseOver()
  local u, v = g.getDimensions()
  local x, y, w, h = self:getRect()
  return math.inside(love.mouse.getX(), love.mouse.getY(), x, y, w, h)
end

function Element:on(...)
  self.event:on(...)
end

function Element:emit(...)
  self.event:emit(...)
end

function Element:getX()
  local u = g.getWidth()
  local x = self.x > 1 and self.x or self.x * u
  local padding = type(self.padding) == 'table' and self.padding.x or self.padding
  if padding < 1 then padding = padding * u end
  if self.anchor == 'right' then x = u - x - self:getWidth() end
  return x + padding
end

function Element:getY()
  local v = g.getHeight()
  local y = self.y > 1 and self.y or self.y * v
  local padding = type(self.padding) == 'table' and self.padding.y or self.padding
  if padding < 1 then padding = padding * v end
  return y + padding
end

function Element:getWidth()
  local u = g.getWidth()
  local w = self.width > 1 and self.width or self.width * u
  local padding = type(self.padding) == 'table' and self.padding.x or self.padding
  if padding < 1 then padding = padding * u end
  return w - 2 * padding
end

function Element:getHeight()
  local v = g.getHeight()
  local h = self.height > 1 and self.height or self.height * v
  local padding = type(self.padding) == 'table' and self.padding.y or self.padding
  if padding < 1 then padding = padding * v end
  return h - 2 * padding
end

function Element:getRect()
  return self:getX(), self:getY(), self:getWidth(), self:getHeight()
end
