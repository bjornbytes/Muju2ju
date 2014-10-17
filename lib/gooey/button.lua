require 'lib/gooey/label'

Button = extend(Label)

local g = love.graphics

Button.font = nil
Button.size = 'auto'
Button.text = ''
Button.color = {255, 255, 255}

function Button:init(data)
  self.active = false
  self.hover = false

  Label.init(self, data)
end

function Button:update()
  local hover = self:mouseOver()
  if hover and not self.hover then
    self:emit('hovered', {element = self})
  elseif not hover and self.hover then
    self:emit('unhovered', {element = self})
  end
  self.hover = hover
end

function Button:draw()
  Label.draw(self)
end

function Button:mousepressed(x, y, b)
  local u, v = g.getDimensions()

  if not self.hover then return end

  if b == 'l' then self.active = true end

  self:emit('mousepressed', {
    element = self,
    x = x * u,
    y = y * v,
    b = b
  })
end

function Button:mousereleased(x, y, b)
  local u, v = g.getDimensions()

  if not self.hover then return end

  self:emit('mousereleased', {
    element = self,
    x = x * u,
    y = y * v,
    b = b
  })

  if self.active and b == 'l' then
    self:emit('clicked', {
      element = self,
      x = x * u,
      y = y * v
    })
  end

  self.active = false
end
