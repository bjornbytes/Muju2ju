local rich = require 'lib/deps/richtext/richtext'

RichText = extend(Element)

local g = love.graphics

RichText.font = nil
RichText.size = 'auto'
RichText.color = {255, 255, 255}
RichText.richtext = nil

function RichText:init(data)
  Element.init(self, data)
end

function RichText:render()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding

  Element.render(self)

  g.setFont(self.font, self.size == 'auto' and self:autoFontSize() or self.size * v)
  g.setColor(self.color)

  if not self.rt then
    love.graphics.push()
    love.graphics.origin()
    self.rt = rich.new(self.richtext)
    love.graphics.pop()
  end

  self.rt:draw(x, y - (g.getFont():getHeight() - g.getFont():getAscent()))
end
