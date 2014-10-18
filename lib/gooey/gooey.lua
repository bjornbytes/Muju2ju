Gooey = class()

local g = love.graphics

function Gooey:init(template)
  self.elements = {}
  self.ids = {}

  for i = 1, #template do
    local el = self:createElement(template[i], template[i].class and template.classes[template[i].class])
    table.insert(self.elements, el)
  end

  self.focused = nil
end

function Gooey:update() self:with('update') end
function Gooey:draw() self:with('draw') end
function Gooey:keypressed(...) self:with('keypressed', ...) end
function Gooey:keyreleased(...) self:with('keyreleased', ...) end
function Gooey:mousepressed(...) self:with('mousepressed', ...) end
function Gooey:mousereleased(...) self:with('mousereleased', ...) end
function Gooey:textinput(...) self:with('textinput', ...) end

function Gooey:createElement(data, base)
  data.properties = table.merge(data.properties, base and table.copy(base) or {})

  local el = _G[data.kind](data.properties)

  if data.id then
    el.id = data.id
    self.ids[data.id] = el
  end

  el.gooey = self

  return el
end

function Gooey:find(id)
  if type(id) ~= 'string' or not id then return end
  return self.ids[id]
end

function Gooey:with(key, ...)
  for _, el in ipairs(self.elements) do f.exe(el[key], el, ...) end
end

function Gooey:unfocus()
  if self.focused then f.exe(self.focused.unfocus, self.focused) end
end

function Gooey:focus(el)
  self:unfocus()
  self.focused = el
  f.exe(self.focused.focus, self.focused)
end

