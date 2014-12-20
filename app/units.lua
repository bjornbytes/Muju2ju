Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)

  self.base = _G['Unit' .. ctx.tag:capitalize()]

  ctx.event:on('unitCreate', function(info)
    if not self.objects[info.id] then
      self:add(info.kind, {id = info.id, owner = ctx.players:get(info.owner), x = info.x})
    end
  end)

  ctx.event:on('unitDestroy', function(info)
    self.objects[info.id]:die()
    self:remove(self.objects[info.id])
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
