Manager = class()

function Manager:init(manages)
  self.objects = {}
  self.manages = self.manages or manages
end

function Manager:update()
  table.with(self.objects, 'update')
end

function Manager:add(kind, vars)
  local object = data[self.manages][kind]()
  table.merge(vars, object, true)
  f.exe(object.activate, object)
  self.objects[object] = object
end

function Manager:remove(object)
  f.exe(object.deactivate, object)
  self.objects[object] = nil
  object = nil
end

function Manager:each(fn)
  table.each(self.objects, fn)
end

function Manager:filter(fn)
  return table.filter(self.objects, fn)
end

function Manager:count()
  if not next(self.objects) then return 0 end
  return table.count(self.objects)
end
