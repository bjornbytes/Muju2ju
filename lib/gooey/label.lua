Label = extend(Element)

local g = love.graphics

Label.font = nil
Label.size = 'auto'
Label.text = ''
Label.color = {255, 255, 255}

function Label:init(data)
  Element.init(self, data)
end

function Label:render()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding

  Element.render(self)

  g.setFont(self.font, self.size == 'auto' and self:autoFontSize() or self.size * v)
  g.setColor(self.color)
  g.print(self.text, x, y - (g.getFont():getHeight() - g.getFont():getAscent()))
end
