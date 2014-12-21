Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)

  self.base = _G['Unit' .. ctx.tag:capitalize()]

  ctx.event:on('unitCreate', function(data)
    if not self.objects[data.id] then
      self:add(data.kind, {id = data.id, player = ctx.players:get(data.owner), x = data.x})
    end
  end)
end

function Units:add(class, vars)
  local unit = setmetatable({}, {__index = self.base})
  table.merge(vars, unit, true)
  unit.class = data.unit[class]
  unit.id = self.nextId
  self.nextId = self.nextId + 1
  if self.nextId >= 1024 then
    if self.objects[1] then print('uh oh we have too many ' .. self.manages) end
    self.nextId = 1
  end
  f.exe(unit.activate, unit)
  self.objects[unit.id] = unit

  return unit
end
