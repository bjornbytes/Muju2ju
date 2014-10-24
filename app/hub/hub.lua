local hub = require('socket').tcp()
local http = require('socket.http')
local json = require('spine-love/dkjson')

local receiveQueue = love.thread.getChannel('hubReceiveQueue')
local sendQueue = love.thread.getChannel('hubSendQueue')

local serverAddress = '96.126.101.55'

local buffer = ''
local function carry(line)
  if not line then return end
  buffer = buffer .. line
  while true do
    local idx = buffer:find('\n')
    if not idx then break end
    local message = buffer:sub(1, idx)
    print('hub received: ' .. message)
    receiveQueue:push(message)
    buffer = buffer:sub(idx + 1)
  end
end

local function formatPost(data)
  if not data then return '' end
  local t = {}
  for k, v in pairs(data) do t[#t + 1] = k .. '=' .. v end
  return table.concat(t, '&')
end

local success, e = hub:connect(serverAddress, 8001)
if e then error(e) end

hub:settimeout(.1)

while true do

  -- Receive stuff
  all, e, line = hub:receive(1000)
  if e then carry(line)
  else carry(all) end

  -- Send stuff
  local str = sendQueue:pop()
  while str do
    local message = json.decode(str)

    if message.cmd == 'login' then
      local str, code = http.request('http://' .. serverAddress .. ':7000/api/users/login', formatPost(message.payload))

      local data
      if code == 200 then
        data = {cmd = 'login', payload = json.decode(str)}
      else
        data = {cmd = 'login', payload = {error = code}}
      end

      receiveQueue:push(json.encode(data))
    elseif message.cmd == 'signup' then
      local str, code = http.request('http://' .. serverAddress .. ':7000/api/users/signup', formatPost(message.payload))

      local data
      if code == 200 then
        data = {cmd = 'signup', payload = json.decode(str)}
      else
        data = {cmd = 'signup', payload = {error = code}}
      end

      receiveQueue:push(json.encode(data))
    else
      print('hub sending: ' .. str)
      local bytes, e = hub:send(str .. '\n')
      if e then print('send error: ' .. e) end
    end

    str = sendQueue:pop()
  end
end

