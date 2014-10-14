TextField = extend(Element)

local g = love.graphics

TextField.font = nil
TextField.size = 'auto'
TextField.text = ''
TextField.color = {255, 255, 255}
TextField.placeholder = ''
TextField.cursor = true
TextField.binds = {}

TextField.binds.all = {
  backspace = function(self)
    self.text = self.text:sub(1, math.max(self.cursorPosition - 1, 0)) .. self.text:sub(self.cursorPosition + 1)
    self.cursorPosition = math.max(self.cursorPosition - 1, 0)
  end,

  left = function(self) self.cursorPosition = math.max(self.cursorPosition - 1, 0) end,
  right = function(self) self.cursorPosition = math.min(self.cursorPosition + 1, #self.text) end,

  home = function(self) self.cursorPosition = 0 end,
  ['end'] = function(self) self.cursorPosition = #self.text end
}

TextField.binds.osx = {
  left = {
    lgui = TextField.binds.all.home,
    none = TextField.binds.all.left
  },

  right = {
    lgui = TextField.binds.all['end'],
    none = TextField.binds.all.right
  }
}

function TextField:init(data)
  Element.init(self, data)

  self.focused = false
  self.default = self.text
  self.cursorPosition = 0
  self.cursorx = 0
end

function TextField:render()
  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding

  Element.render(self)

  local text = self.renderFilter and self.renderFilter(self.text) or self.text

  g.setFont(self.font, self.size == 'auto' and self:autoFontSize() or self.size * v)
  local c = self.color
  if #text == 0 then
    g.setColor(c[1], c[2], c[3], (c[4] or 255) / 2)
    g.print(self.placeholder, x, y)
  else
    g.setColor(self.color)
    g.print(text, x, y)
  end

  if self.focused and self.cursor then
    local cursorx = x
    if self.cursorPosition > 0 then
      cursorx = x + g.getFont():getWidth(text:sub(1, self.cursorPosition))
    end
    cursorx = cursorx + 1
    self.cursorx = math.lerp(self.cursorx, cursorx, 8 * tickRate)
    self.cursorx = math.clamp(self.cursorx, x, x + g.getFont():getWidth(text .. 'M'))
    g.setColor(self.color)
    g.line(self.cursorx, y, self.cursorx, y + g.getFont():getHeight())
  end
end

function TextField:keypressed(key) 
  if self.focused then
    self:emit('keypressed', {element = self, key = key})
    local os = love.system.getOS():gsub(' ', ''):gsub('%a', string.lower)
    local method = (self.binds[os] and self.binds[os][key]) or self.binds.all[key]
    if type(method) == 'function' then return method(self)
    elseif type(method) == 'table' then
      for modifier, method in pairs(method) do
        if love.keyboard.isDown(modifier) then return method(self) end
      end
      if type(method.none) == 'function' then method.none(self) end
    end
  end
end

function TextField:mousepressed(mx, my, button)
  Element.mousepressed(self, mx, my, button)
  if button == 'l' and not self.focused and self:mouseOver() then self.owner:focus(self) end

  local u, v = self.owner.frame.width, self.owner.frame.height
  local x, y = self.x * u + self.padding, self.y * v + self.padding
  g.setFont(self.font, self.size == 'auto' and self:autoFontSize() or self.size * v)

  local text = self.renderFilter and self.renderFilter(self.text) or self.text

  self.cursorPosition = 0
  if x + g.getFont():getWidth(text) < mx then
    self.cursorPosition = #text
  else
    local function subwidth(pos) return g.getFont():getWidth(text:sub(1, pos)) end
    while x + subwidth(self.cursorPosition) < mx and self.cursorPosition < #text do
      self.cursorPosition = self.cursorPosition + 1
    end
    if (x + subwidth(self.cursorPosition)) - mx > (subwidth(self.cursorPosition) - subwidth(self.cursorPosition - 1)) / 2 then
      self.cursorPosition = self.cursorPosition - 1
    end
  end
end

function TextField:mousereleased(x, y, button)
  Element.mousereleased(self, x, y, button)
  if button == 'l' and self.focused and not self:mouseOver() then self.owner:unfocus() end
end

function TextField:textinput(char)
  Element.textinput(self, char)
  if self.focused then
    self.text = self.text:sub(1, self.cursorPosition) .. char .. self.text:sub(self.cursorPosition + 1)
    self.cursorPosition = self.cursorPosition + 1
  end
end

function TextField:focus()
  self.focused = true
  if self.text == self.default then self.text = '' end
end

function TextField:unfocus()
  self.focused = false
  if self.text == '' then self.text = self.default end
end
