Button = extend(Label)

local g = love.graphics

Button.font = nil
Button.size = 'auto'
Button.text = ''
Button.color = {255, 255, 255}

function Button:init(data)
  Label.init(self, data)
end

function Button:render()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding

  Label.render(self)
end

