require 'lib/gooey/element'

Label = extend(Element)

local g = love.graphics

Label.font = nil
Label.size = 'auto'
Label.text = ''
Label.color = {255, 255, 255}

function Label:init(data)
  Element.init(self, data)
end

function Label:draw()
  local u, v = g.getDimensions()
  local x, y, w, h = self:getRect()

  Element.draw(self)

  g.setFont(self.font, self.size == 'auto' and self:autoFontSize() or self.size * v)
  g.setColor(self.color)

  if self.center then
    x = (x + w / 2) - g.getFont():getWidth(self.text) / 2
    y = (y + h / 2) - g.getFont():getHeight() / 2
  end

  g.print(self.text, x, y)
end
