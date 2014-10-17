Net = class()

Net.messageMap = {
  'join',
  'leave',
  'ready',
  'over',
  'bootstrap',
  'input',
  'snapshot',
  'chat',
  'unitCreate',
  'unitDestroy',
  'jujuCreate',
  'jujuCollect',
  'spellCreate'
}

table.each(Net.messageMap, function(message, i) Net.messageMap[message] = i end)

function Net:init()
  self.inStream = Stream()
  self.outStream = Stream()
end

function Net:listen(port)
  self.host = enet.host_create(port and '*:' .. port or nil, port and #ctx.config.players or 1, 2)
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
  if not self.messageMap[msg] then print('Tried to send invalid message ' .. msg) end

  local function halp()
    self.outStream:write(self.messageMap[msg], 5)
    self.outStream:pack(data, self.messages[msg])
  end

  xpcall(halp, function(err)
    print('Error sending message "' .. msg .. '"')
    table.print(data)
    print('\t' .. debug.traceback(err, 3):gsub('stack traceback:\n', ''))
  end)
end

function Net:unpack()
  local success, msg = pcall(self.inStream.read, self.inStream, 5)

  if not success then return end

  local function halp()
    msg = self.messageMap[msg]
    if not self.other.messages[msg] then return false end
    return msg, self.inStream:unpack(self.other.messages[msg])
  end

  local success, msg, data = xpcall(halp, function(err)
    print('Error unpacking message "' .. msg .. '":')
    print('\t' .. debug.traceback(err, 3):gsub('stack traceback:\n', ''))
  end)

  return msg, data
end
