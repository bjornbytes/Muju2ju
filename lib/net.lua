Net = class()

Net.messageMap = {
  'join',
  'leave',
  'ready',
  'input',
  'snapshot',
  'unitCreate',
  'unitDestroy',
  'jujuCreate',
  'jujuCollect'
}

table.each(Net.messageMap, function(message, i) Net.messageMap[message] = i end)

function Net:init()
  self.inStream = Stream()
  self.outStream = Stream()
end

function Net:listen(port)
  self.host = enet.host_create(port and '*:' .. port or nil, 16, 2)
  if not self.host then error('Error creating the connection') end
end

function Net:connectTo(ip, port)
  if not self.host then self:listen() end
  local peer = self.host:connect(ip .. ':' .. port, 2)
  peer:timeout(0, 0, 3000)
end

function Net:update()
  while true do
    if not self.host then break end
    local event = self.host:service()
    if not event then break end
    
    if event.type == 'receive' then
      self.inStream:clear()
      self.inStream.str = event.data

      while true do
        event.msg, event.data = self:unpack()
        if not event.msg or not self.messages[event.msg] then break end
        f.exe(self.messages[event.msg].receive, self, event)
      end
    else
      f.exe(self[event.type], self, event)
    end
  end
end

function Net:pack(msg, data)
  assert(type(msg) == 'string' and self.messages[msg])
  self.outStream:write(self.messageMap[msg], 5)
  self.outStream:pack(data, self.messages[msg])
end

function Net:unpack()
  local msg = self.inStream:read(5)
  msg = self.messageMap[msg]
  if not self.other.messages[msg] then return false end
  return msg, self.inStream:unpack(self.other.messages[msg])
end
