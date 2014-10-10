Element = class()

local g = love.graphics

Element.x = 0
Element.y = 0
Element.width = 1
Element.height = 1
Element.padding = 0

function Element:init(data)
  self.parent = nil
  self.children = {}

  table.merge(data, self)
end

function Element:update()
  self:callChildren('update')
end

function Element:draw()
  self:render()
  self:callChildren('draw')
end

function Element:render()
  local u, v = self.owner.frame.width, self.owner.frame.height

  if self.background then
    if self.background.typeOf and self.background:typeOf('Drawable') then
      g.setColor(255, 255, 255)
      g.draw(self.background, self.x * u, self.y * v, 0, self.width / self.background:getWidth() * u, self.height / self.background:getHeight() * v)
    else
      g.setColor(self.background)
      g.rectangle('fill', self.x * u, self.y * v, self.width * u, self.height * v)
    end
  end

  if self.border then
    g.setColor(self.border)
    g.rectangle('line', math.round(self.x * u) + .5, math.round(self.y * v) + .5, self.width * u, self.height * v)
  end
end

function Element:callChildren(key, ...)
  self.owner:push(self, key == 'draw')
  table.with(self.children, key, ...)
  self.owner:pop(self, key == 'draw')
end

function Element:keypressed(...)
  self:callChildren('keypressed', ...)
end

function Element:keyreleased(...)
  self:callChildren('keyreleased', ...)
end

function Element:mousepressed(...)
  self:callChildren('mousepressed', ...)
end

function Element:mousereleased(...)
  self:callChildren('mousereleased', ...)
end

function Element:textinput(...)
  self:callChildren('textinput', ...)
end

function Element:add(child)
  child.parent = self
  child.owner = self.owner
  table.insert(self.children, child)

  if child.name then
    if child.name:find('[]') then
      child.name = child.name:sub(1, -2)
      if not self[child.name] then
        self[child.name] = self[child.name] or {}
        table.insert(self[child.name], child)
      end
    elseif not self[child.name] then
      self[child.name] = child
    end
  end

  return child
end

function Element:autoFontSize()
  return self.height * self.owner.frame.height - self.padding * 2
end

function Element:mouseOver()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.owner.frame.x + self.x * u, self.owner.frame.y + self.y * v
  local w, h = self.width * u, self.height * v
  return math.inside(love.mouse.getX(), love.mouse.getY(), x, y, w, h)
end
