require 'lib/gooey/label'

Button = extend(Label)

local g = love.graphics

Button.font = nil
Button.size = 'auto'
Button.text = ''
Button.color = {255, 255, 255}

function Button:init(data)
  Label.init(self, data)

  self.active = false
  self.hover = false
end

function Button:update()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding
  local mx, my = love.mouse.getPosition()

  local hover = math.inside(mx, my, self.x * u, self.y * v, self.width * u, self.height * v)
  if hover and not self.hover then
    self:emit('hovered', {element = self})
  elseif not hover and self.hover then
    self:emit('unhovered', {element = self})
  end
  self.hover = hover
end

function Button:render()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding

  if self.hover then
    
  end

  Label.render(self)
end

function Button:mousepressed(x, y, b)
  if not self.hover then return end

  if b == 'l' then self.active = true end

  self:emit('mousepressed', {
    element = self,
    x = x,
    y = y,
    b = b
  })
end

function Button:mousereleased(x, y, b)
  if not self.hover then return end

  self:emit('mousereleased', {
    element = self,
    x = x,
    y = y,
    b = b
  })

  if self.active and b == 'l' then
    self:emit('clicked', {
      element = self,
      x = x,
      y = y
    })
  end

  self.active = false
end
