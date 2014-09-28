Net = class()

evtReady = 1
evtLeave = 2
evtSync = 3
evtSummon = 4
evtDeath = 5
evtSpawn = 6

msgJoin = 7
msgLeave = 8
msgInput = 9

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
        if not event.msg then break end
        ;(self.handlers[event.msg] or self.handlers.default)(self, event)
      end
    else
      f.exe(self[event.type], self, event)
    end
  end
end

function Net:pack(msg, data)
  self.outStream:write(msg, '5bits')
  self.outStream:pack(data, self.signatures[msg])
end

function Net:unpack()
  local msg = self.inStream:read('5bits')
  if not self.other.signatures[msg] then return false end
  return msg, self.inStream:unpack(self.other.signatures[msg])
end
