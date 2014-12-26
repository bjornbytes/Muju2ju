MenuTextInput = class()

MenuTextInput.binds = {}
MenuTextInput.binds.all = {
  backspace = function(self)
    local text = self.text[self.focused]
    self.text[self.focused] = text:sub(1, math.max(self.cursorPosition - 1, 0)) .. text:sub(self.cursorPosition + 1)
    self.cursorPosition = math.max(self.cursorPosition - 1, 0)
  end,

  left = function(self) self.cursorPosition = math.max(self.cursorPosition - 1, 0) end,
  right = function(self) self.cursorPosition = math.min(self.cursorPosition + 1, #self.text[self.focused]) end,

  home = function(self) self.cursorPosition = 0 end,
  ['end'] = function(self) self.cursorPosition = #self.text[self.focused] end
}

MenuTextInput.binds.osx = {
  left = {
    lgui = MenuTextInput.binds.all.home,
    none = MenuTextInput.binds.all.left
  },

  right = {
    lgui = MenuTextInput.binds.all['end'],
    none = MenuTextInput.binds.all.right
  }
}


function MenuTextInput:init()
  self.text = {}
  self.placeholders = {}
  self.focused = nil
  self.cursorPosition = 0
end

function MenuTextInput:keypressed(key)
  if self.focused then
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

function MenuTextInput:textinput(char)
  if self.focused then
    local text = self.text[self.focused]
    self.text[self.focused] = text:sub(1, self.cursorPosition) .. char .. text:sub(self.cursorPosition + 1)
    self.cursorPosition = self.cursorPosition + 1
  end
end

function MenuTextInput:add(code, text, placeholder)
  self.text[code] = text
  self.placeholders[code] = placeholder
end

function MenuTextInput:focus(code)
  self.focused = code
  self.cursorPosition = #self.text[self.focused]
end

function MenuTextInput:unfocus()
  self.focused = nil
end
