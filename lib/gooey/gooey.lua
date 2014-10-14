Gooey = class()

local g = love.graphics

function Gooey:init(template)
  self.elements = {}
  self.stack = {}
  self.ids = {}

  self.event = Event()

  for i = 1, #template do
    local el = self:createElement(template[i], template[i].class and template.classes[template[i].class])
    table.insert(self.elements, el)
  end

  self.focused = nil
end

function Gooey:update()
  self:with('update')
end

function Gooey:draw()
  love.graphics.push()
  self:with('draw')
  love.graphics.pop()
end

function Gooey:keypressed(...) self:with('keypressed', ...) end
function Gooey:keyreleased(...) self:with('keyreleased', ...) end
function Gooey:mousepressed(...) self:with('mousepressed', ...) end
function Gooey:mousereleased(...) self:with('mousereleased', ...) end
function Gooey:textinput(...) self:with('textinput', ...) end

function Gooey:createElement(data, base)
  data.properties = table.merge(data.properties, base and table.copy(base) or {})

  local el = _G[data.kind](data.properties)
  el.owner = self

  if data.id then
    el.id = data.id
    self.ids[data.id] = el
  end

  if not data.children then return el end
  for i = 1, #data.children or {} do
    el:add(self:createElement(data.children[i]))
  end

  return el
end

function Gooey:find(id)
  if type(id) ~= 'string' or not id then return end
  return self.ids[id]
end

function Gooey:with(key, ...)
  self.frame = self.frame or {x = 0, y = 0, width = love.graphics.getWidth(), height = love.graphics.getHeight()}
  for _, el in ipairs(self.elements) do f.exe(el[key], el, ...) end
  self.frame = nil
end

function Gooey:push(element, drawing)
  table.insert(self.stack, {x = self.frame.x, y = self.frame.y, width = self.frame.width, height = self.frame.height})
  if drawing then
    love.graphics.push()
    love.graphics.translate(element.x * self.frame.width, element.y * self.frame.height)
  end
  self.frame.x = self.frame.x + element.x
  self.frame.y = self.frame.y + element.y
  self.frame.width = self.frame.width * element.width - 2
  self.frame.height = self.frame.height * element.height - 2
end

function Gooey:pop(element, drawing)
  if drawing then love.graphics.pop() end
  table.merge(self.stack[#self.stack], self.frame)
  table.remove(self.stack)
end

function Gooey:unfocus()
  if self.focused then f.exe(self.focused.unfocus, self.focused) end
end

function Gooey:focus(el)
  self:unfocus()
  self.focused = el
  f.exe(self.focused.focus, self.focused)
end

