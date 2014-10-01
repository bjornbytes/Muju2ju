Jujus = extend(Manager)

function Jujus:init()
  Manager.init(self)

  ctx.event:on('jujuCreate', function(data)
    self:add({id = data.id, x = data.x, y = data.y})
  end)

  ctx.event:on('jujuDestroy', function(data)
    self:remove(self.objects[data.id])
  end)
end

function Jujus:add(data)
  local juju = Juju()
  table.merge(data, juju)
  juju.id = self.nextId
  self.nextId = self.nextId + 1
  if self.nextId >= 1024 then
    if self.objects[1] then print('uh oh we have too much juju') end
    self.nextId = 1
  end
  f.exe(juju.activate, juju)
  self.objects[juju.id] = juju
  return juju
end
